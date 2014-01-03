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
        logger = ExecutionLogger.new(application: @application, trigger: trigger)
        logger.message = message
        begin
          return DatabaseExecutionContext.execute(@application, trigger, MessagePlaceholderSolver.new(message, trigger, match), logger)
        rescue Exception => e
          logger.error(e.message)
        ensure
          logger.save!
        end
      end
    end
    logger = ExecutionLogger.new(application: @application)
    logger.message = message
    logger.error("No trigger found.")
    logger.save!
    nil
  end
end
