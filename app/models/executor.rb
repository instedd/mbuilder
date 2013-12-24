class Executor
  def initialize(application)
    @application = application
    @triggers = application.message_triggers.all
  end

  def execute(message)
    body = message['body']

    @triggers.each do |trigger|
      match = trigger.match(body)
      if match
        logger = ExecutionLogger.new(application: @application)
        # logger.trigger = trigger
        return DatabaseExecutionContext.execute(@application, trigger, MessagePlaceholderSolver.new(message, trigger, match, logger), logger)
      end
    end

    nil
  end
end
