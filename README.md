future
======

A seemless proxy future object framework for jruby to do work in parallel

Usage
-----

First, create a thread pool executor to execute the tasks. Ideally this should be done in the application initializer.
``` ruby
executor = JFuture::ExecutorFactory.create
```

Its is recommended that you give a name for the executor (default name is `:default`). Below we create a thread pool executor with all available options:
``` ruby
executor = JFuture::ExecutorFactory.create(name: :my_pool)
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
people = JFuture.new(executor: :my_pool) { Person.all }  # makes async call to database and returns the result as a future object
cars = JFuture.new(executor: :my_pool) { Car.all }  	    # makes async call to database and returns the result as a future object
people.do_something  									# waits on the future object to be popluated and only then is the method call executed
cars.do_something    									# waits on the future object to be popluated and only then is the method call executed
```


ExecutorFactory options with defaults
-------------------------------------
``` ruby
executor = JFuture::ExecutorFactory.create(core_pool_size: 20,
          max_pool_size: 20,
          keep_alive_millis: 120000,
          queue_size: 10,
          name: :default,
          thread_factory: DaemonThreadFactory.new)
```

Submit task to an executor
--------------------------
```JFuture.new``` can take either the name of executor or a reference to an executor
``` ruby
people = JFuture.new(executor: :my_pool) { Person.all }
```
or
``` ruby
people = JFuture.new(executor: executor) { Person.all }
```
Timeouts
--------
Read access timeout on future object can be set as:
``` ruby
people = JFuture.new(executor: executor, access_timeout_millis: 100) { Person.all }
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
restaurant = JFuture.new {Restaurant.find(id)} # get future object
restaurant.on_complete {|restaurant| puts restaurant.name} # set up an async callback
```
by chaining:
``` ruby
JFuture.new {Restaurant.find(id)}.on_complete {|result| puts result.name}
```
The timeout on future applies to the on_complete as well. It will throw a Java::JavaUtilConcurrent::TimeoutException on time out. This error can be handled by adding a rescue block for the error inside on_complete block.
``` ruby
JFuture.new(access_timeout_millis: 1) {Restaurant.find(id)}.on_complete do
  begin
    puts restaurant.name
  rescue Java::JavaUtilConcurrent::TimeoutException
    puts 'task timed out'
  end
end
```
Chaining with on_complete
-------------------------
`.on_complete` returns a `JFuture` object of the result of on_complete block. Its therefore possible to create a chain with `.on_complete`:
``` ruby
JFuture.new { Restaurant.all[0]}.on_complete{|res| res.name}.on_complete{|res|  puts res}
```
Its recommended to avoid chaining when possible as it blocks as many workers as the links in the chain. The workers get unblocked in the order of the chain links.
Its possible to specify the `executor` and `access_timeout_millis` for the `.on_complete` as well.
While the `executor` specified for `.on_complete` will be used to run the `block` of `.on_complete`, the `access_timeout_millis` will apply to the consumer of the result of the `.on_complete` when it tries to read the result of on complete (`access_timeout_millis` always applies to the consumer of the JFuture object)
JFuture objects for each link in the chain are created and consumed in one shot. So the timer for each of the timeouts starts almost at the same time. Hence the timeouts in the chain should be in increasing order (i.e. cumulative of the timeout of the previous link in the chain)
Note:
-----
The `access_timeout_millis` only applies to the thread blocking on future object. the worker thread which computes the future will be blocked for as long as it takes to compute the future object without any timeout applicable to it. So, only pass things into future that will complete.
The callback and future object computation are scheduled as separate tasks possibly taking up different threads. While deciding the number of workers for the executor keep in mind that blocked task with callback results in two blocked workers.

