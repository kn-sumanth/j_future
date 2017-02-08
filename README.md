future
======

A seemless proxy future object framework for jruby to do work in parallel

Usage
-----

First, create a thread pool executor to execute the tasks. Ideally this should be done in the application initializer.
``` ruby
executor = Future::ExecutorFactory.create
```

Its is recommended that you give a name for the executor (default name is `:default`). Below we create a thread pool executor with all available options:
``` ruby
executor = Future::ExecutorFactory.create(name: :my_pool)
```

Let us pick some calls and make them concurrent
``` ruby
people = Person.all  # call to database
people.do_something  # use result by calling methods on it
cars = Car.all   	 # call to database
cars.do_something    # use result by calling methods on it
```
change the above to execute in parallel:
``` ruby
people = Future.new(executor: :my_pool) { Person.all }  # makes async call to database and returns the result as a future object
cars = Future.new(executor: :my_pool) { Car.all }  	    # makes async call to database and returns the result as a future object
people.do_something  									# waits on the future object to be popluated and only then is the method call executed
cars.do_something    									# waits on the future object to be popluated and only then is the method call executed
```


ExecutorFactory options with defaults
-------------------------------------
``` ruby
executor = Future::ExecutorFactory.create(core_pool_size: 10,
          max_pool_size: 10,
          keep_alive_millis: 5000,
          queue_size: 50,
          name: :default,
          thread_factory: DaemonThreadFactory.new)
```

Submit task to an executor
--------------------------
```Future.new``` can take either the name of executor or a reference to an executor
``` ruby
people = Future.new(executor: :my_pool) { Person.all }
```
or
``` ruby
people = Future.new(executor: executor) { Person.all }
```
Timeouts
--------
Read access timeout on future object can be set as:
``` ruby
people = Future.new(executor: executor, access_timeout_millis: 100) { Person.all }
people.do_something # timer is triggered on access
```
on timeout throws exception:
``` ruby
Java::JavaUtilConcurrent::TimeoutException
```
is_done? check
--------------
Check if the future is populated without blocking on it(any method other than is_done? is guranteed to block)
``` ruby
people.is_done?  # true / false
```

Async callbacks on future completion:
-------------------------------------
``` ruby
restaurant = Future.new {Restaurant.find(id)} # get future object
restaurant.on_complete {|restaurant| puts restaurant.name} # set up an async callback
```
by chaining:
``` ruby
Future.new {Restaurant.find(id)}.on_complete {|result| puts result.name}
```
The timeout on future applies to the on_complete as well. It will throw a Java::JavaUtilConcurrent::TimeoutException on time out. This error can be handled by adding a rescue block for the error inside on_complete block.
``` ruby
Future.new(access_timeout_millis: 1) {Restaurant.find(id)}.on_complete do
  begin
    puts restaurant.name
  rescue Java::JavaUtilConcurrent::TimeoutException
    puts 'task timed out'
  end
end
```
Note:
-----
The `access_timeout_millis` only applies to the thread blocking on future object. the worker thread which computes the future will be blocked for as long as it takes to compute the future object without any timeout applicable to it. So, only pass things into future that will complete.
The callback and future object computation are scheduled as separate tasks possibly taking up different threads. While deciding the number of workers for the executor keep in mind that blocked task with callback results in two blocked workers.

