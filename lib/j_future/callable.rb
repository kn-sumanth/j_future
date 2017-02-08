class JFuture < ::BasicObject
  class Callable
    include Java::JavaUtilConcurrent::Callable
    def initialize(arg = nil, &block)
      @block = block
      @arg = arg
    end
    def call
      @block.call @arg
    end
  end
end