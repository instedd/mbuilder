class MessageTriggersController < ApplicationController
  before_filter :authenticate_user!
  before_filter :set_tab

  expose(:application) { current_user.applications.find params[:application_id] }
  expose(:message_triggers) { application.message_triggers }
  expose(:message_trigger)
  expose(:periodic_tasks) { application.periodic_tasks }

  expose(:validation_triggers) do
    validation_triggers = application.validation_triggers.all
    validation_triggers.each { |t| t.application = application }
    validation_triggers
  end

  def create
    set_message_trigger_data(message_trigger)
  end

  def update
    set_message_trigger_data(message_trigger)
  end

  def destroy
    message_trigger.destroy
    redirect_to application_message_triggers_path(application)
  end

  private

  def set_message_trigger_data(trigger)
    data = JSON.parse request.raw_post
    name = data['name']
    message = data['message']
    actions = data['actions']
    tables = data['tables']
    table_and_field_rebinds = data['tableAndFieldRebinds']

    message = Message.from_hash(message)
    actions = Action.from_list(actions)
    trigger.name = name
    trigger.logic = Logic.new message, actions

    application.tables = Table.from_list(tables)

    begin
      ActiveRecord::Base.transaction do
        application.save!
        trigger.save!

        if table_and_field_rebinds
          application.rebind_tables_and_fields(table_and_field_rebinds)
        end
      end
      render json: trigger.id
    rescue ActiveRecord::RecordInvalid
      render json: trigger.errors.full_messages.join("\n"), status: 402
    end
  end

  def set_tab
    @application_tab = :triggers
  end
end
