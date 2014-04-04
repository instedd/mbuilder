class ExternalTriggersController < MbuilderApplicationController
  before_filter do
    add_breadcrumb 'Triggers', application_message_triggers_path(application)
  end
  layout "trigger_edit"
  set_application_tab :triggers

  expose(:message_triggers) { application.message_triggers }
  expose(:external_triggers) { application.external_triggers }
  expose(:external_trigger)
  expose(:periodic_tasks) { application.periodic_tasks }

  expose(:validation_triggers) do
    validation_triggers = application.validation_triggers.all
    validation_triggers.each { |t| t.application = application }
    validation_triggers
  end

  def create
    set_external_trigger_data(external_trigger)
  end

  def edit
    add_breadcrumb external_trigger.name, edit_application_external_trigger_path(application, external_trigger)
  end

  def update
    set_external_trigger_data(external_trigger)
  end

  def destroy
    external_trigger.destroy
    redirect_to application_message_triggers_path(application)
  end

  def run
    trigger = application.external_triggers.find_by_name(params['trigger_name'])

    logger = ExecutionLogger.new(application: @application)

    logger.info "Executing trigger '#{trigger.name}'"
    logger.trigger = trigger
    begin
      @context = DatabaseExecutionContext.execute(application, trigger, ParameterPlaceholderSolver.new(params), logger)
      if @context.messages.present?
        nuntium = Pigeon::Nuntium.from_config
        nuntium.send_ao @context.messages
      end
    rescue Exception => e
      puts e.message
      puts e.backtrace
      logger.error(e.message)
    ensure
      logger.save!
    end

    render_json @context.try(:messages), status: 200

  rescue ActiveRecord::RecordNotFound => e
    logger.error_no_trigger
    logger.save!
    render_json trigger.errors.full_messages.join("\n"), status: 404
  end

  private

  def set_external_trigger_data(trigger)
    data = JSON.parse request.raw_post

    trigger.name = data['name']
    trigger.parameters = Pill.from_list(data['parameters'])
    trigger.actions = Action.from_list(data['actions'])

    application.tables = Table.from_list data['tables']

    begin
      ActiveRecord::Base.transaction do
        application.save!
        trigger.save!

        if data['tableAndFieldRebinds']
          application.rebind_tables_and_fields(data['tableAndFieldRebinds'])
        end
      end
      render_json trigger.id
    rescue ActiveRecord::RecordInvalid
      render_json trigger.errors.full_messages.join("\n"), status: 402
    end
  end
end
