class Executor
  attr_reader :messages
  attr_reader :matching_triggers
  attr_reader :logger

  def initialize(application)
    @application = application
    @triggers = application.message_triggers.all
  end

  def execute(message)
    @logger = ExecutionLogger.new(application: @application)
    @logger.message = message

    @matching_triggers = []
    @messages = []

    body = message['body']

    @triggers.each do |trigger|
      match = trigger.match(body)
      if match
        @logger.info "Executing trigger '#{trigger.name}'"
        @matching_triggers << trigger
        begin
          context = DatabaseExecutionContext.execute(@application, trigger, MessagePlaceholderSolver.new(message, trigger, match), @logger)
          @messages.concat context.messages
        rescue Exception => e
          puts e.message
          puts e.backtrace
          @logger.error(e.message)
        ensure
          @logger.save!
        end
      end
    end

    case @matching_triggers.length
    when 0
      @logger.error "No trigger matched the message."
    when 1
      @logger.trigger = @matching_triggers.first
    end

    @logger.save!

    self
  end
end
