require 'java'
require_relative 'future/version'
require_relative 'future/callable'
class Future < ::BasicObject
  def initialize(executor_service:, &block)
    callable = Callable.new(&block)
    @future = executor_service.submit callable
  end
  def respond_to?(id, *args)
    @future.get.respond_to?(id, *args)
  end
  def method_missing(name, *args, &block)
    @future.get.send(name, *args, &block)
  end
end