class Future < ::BasicObject
  class DaemonThreadFactory
    include Java::JavaUtilConcurrent::ThreadFactory
    def newThread(runnable)
      thread = Java::JavaUtilConcurrent::Executors.defaultThreadFactory().newThread(runnable)
      thread.setDaemon(true)
      thread
    end
  end
end