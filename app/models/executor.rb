class Executor
  def initialize(application)
    @application = application
    @triggers = application.triggers.all
  end

  def execute(message)
    body = message['body']

    @triggers.each do |trigger|
      pattern = /#{trigger.pattern}/
      match = pattern.match(body)
      if match
        return TireExecutionContext.execute(@application, trigger, message, match)
      end
    end

    nil
  end
end

