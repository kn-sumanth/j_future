require 'java'
require_relative 'future/version'
require_relative 'future/callable'
require_relative 'future/daemon_thread_factory'
require_relative 'future/executor_factory'
class Future < ::BasicObject
  def initialize(executor: :default, &block)
    callable = Callable.new(&block)
    if (executor.is_a? ::Java::JavaUtilConcurrent::AbstractExecutorService)
      @future = executor.submit callable
    else
      @future = ExecutorFactory.get_executor(executor).submit callable
    end
  end
  def respond_to?(id, *args)
    @future.get.respond_to?(id, *args)
  end
  def method_missing(name, *args, &block)
    @future.get.send(name, *args, &block)
  end
end