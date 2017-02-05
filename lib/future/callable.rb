class Future < ::BasicObject
  class Callable
    include Java::JavaUtilConcurrent::Callable
    def initialize(&block)
      @block = block
    end
    def call
      @block.call
    end
  end
end