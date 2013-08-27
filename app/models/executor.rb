class Executor
  def initialize(application)
    @application = application
    @triggers = application.triggers.all
  end

  def execute(message)
    body = message[:body]

    @triggers.each do |trigger|
      pattern = /#{trigger.pattern}/
      match = pattern.match(body)
      if match
        context = ExecutionContext.new(@application, trigger, message, match)
        trigger.execute(context)
        context.finish
        return context
      end
    end
  end
end

