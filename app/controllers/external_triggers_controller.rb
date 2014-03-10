class ExternalTriggersController < ApplicationController
  before_filter :authenticate_user!, except: :run
  before_filter :authenticate_api_user!, only: :run

  before_filter :set_tab

  expose(:application) { current_user.applications.find params[:application_id] }
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

  def update
    set_external_trigger_data(external_trigger)
  end

  def destroy
    external_trigger.destroy
    redirect_to application_message_triggers_path(application)
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

  def set_tab
    @application_tab = :triggers
  end
end
