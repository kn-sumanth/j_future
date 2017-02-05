future
======

A seemless async future object frame work for ruby

Usage
-----

First, create a thread pool executor to execute the async tasks. Ideally this should be done in the application initializer.
``` ruby
executor = Future::ExecutorFactory.create
```

Its is recommended that you give a name for the executor (default name is `:default`). Below we create a thread pool executor with all available options:
``` ruby
executor = Future::ExecutorFactory.create(name: :my_pool)
```

Let us pick some calls to make async
``` ruby
people = Person.all  # call to database
people.do_something  # use result by calling methods on it
cars = Car.all   	 # call to database
cars.do_something    # use result by calling methods on it
```
change the above to async:
``` ruby
people = Future.new(executor: :my_pool) { Person.all }  # makes async call to database and returns the result as a future object
cars = Future.new(executor: :my_pool) { Car.all }  	    # makes async call to database and returns the result as a future object
people.do_something  									# waits on the future object to be popluated and only then is the method call executed
cars.do_something    									# waits on the future object to be popluated and only then is the method call executed
```


ExecutorFactory options with defaults:
--------------------------------------
``` ruby
executor = Future::ExecutorFactory.create(core_pool_size: 10,
          max_pool_size: 10,
          keep_alive_millis: 5000,
          queue_size: 50,
          name: :default,
          thread_factory: DaemonThreadFactory.new)
```

```Future.new``` can take either the name of executor or a reference to an executor
------------------------------------------------------------------------------------
``` ruby
people = Future.new(executor: :my_pool) { Person.all }
```
or
``` ruby
people = Future.new(executor: executor) { Person.all }
```

Read access timeout on future object can be set as:
---------------------------------------------------
``` ruby
people = Future.new(executor: executor, access_timeout_millis: 100) { Person.all }
people.do_something # timer is triggered on access
```
on timeout throws exception:
``` ruby
Java::JavaUtilConcurrent::TimeoutException
```

Check if the future is populated without blocking on it(any method other than is_done? is guranteed to block)
``` ruby
people.is_done?  # true / false
```
