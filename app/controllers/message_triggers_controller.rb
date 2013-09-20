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

    trigger.name = data['name']
    trigger.message = Message.from_hash(data['message'])
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
      render json: trigger.id
    rescue ActiveRecord::RecordInvalid
      render json: trigger.errors.full_messages.join("\n"), status: 402
    end
  end

  def set_tab
    @application_tab = :triggers
  end
end
