class JFuture < ::BasicObject
  class ExecutorFactory
    @@executor_map = {}
    def self.create(core_pool_size: 20,
          max_pool_size: 20,
          keep_alive_millis: 120000,
          queue_size: 10,
          name: :default,
          thread_factory: DaemonThreadFactory.new)

      work_queue = queue_size.to_i > 0 ?
                    Java::JavaUtilConcurrent::LinkedBlockingQueue.new(queue_size.to_i) :
                    Java::JavaUtilConcurrent::SynchronousQueue.new
      executor = Java::JavaUtilConcurrent::ThreadPoolExecutor.new(
                    core_pool_size.to_i,
                    max_pool_size.to_i,
                    keep_alive_millis.to_i,
                    MILLIS,
                    work_queue,
                    thread_factory)
      @@executor_map[name] = executor
    end

    def self.get_executor(name = :default)
      @@executor_map[name]
    end
  end
end