require 'java'
require_relative 'j_future/version'
require_relative 'j_future/callable'
require_relative 'j_future/daemon_thread_factory'
require_relative 'j_future/executor_factory'
class JFuture < ::BasicObject
  MILLIS = ::Java::JavaUtilConcurrent::TimeUnit::MILLISECONDS
  METHODS = [:is_done?, :on_complete]

  def initialize(executor: :default, access_timeout_millis: nil, &block)
    @access_timeout_millis = access_timeout_millis
    callable = Callable.new(&block)
    if (executor.is_a? ::Java::JavaUtilConcurrent::AbstractExecutorService)
      @executor = executor
    else
      @executor = ExecutorFactory.get_executor(executor)
    end
    @future = @executor.submit callable
  end

  def respond_to?(id, *args)
    return true if METHODS.include?(id)
    if @access_timeout_millis.nil?
      @future.get.respond_to?(id, *args)
    else
      @future.get(@access_timeout_millis.to_i, MILLIS).respond_to?(id, *args)
    end
  end

  def is_done?
    @future.isDone
  end

  def on_complete(&block)
    callback = Callable.new(self, &block)
    @executor.submit callback
  end

  def method_missing(name, *args, &block)
    if @access_timeout_millis.nil?
      @future.get.send(name, *args, &block)
    else
      @future.get(@access_timeout_millis.to_i, MILLIS).send(name, *args, &block)
    end
  end
end