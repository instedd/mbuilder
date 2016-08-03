class ValidationTriggersController < MbuilderApplicationController
  before_filter do
    add_breadcrumb 'Triggers', application_message_triggers_path(application)
  end
  layout "trigger_edit"
  set_application_tab :triggers

  def show
    load_validation_trigger

    if params[:valid_values]
      field = application.table_of(params[:id]).find_field(params[:id])
      field.valid_values = params[:valid_values]
    end

    add_breadcrumb @validation_trigger.field_name
  end

  def update
    load_validation_trigger
    data = JSON.parse request.raw_post

    @validation_trigger.from = data['from']
    @validation_trigger.invalid_value = data['invalid_value']
    @validation_trigger.actions = Action.from_list data['actions']

    application.tables = Table.from_list(data['tables'])

    begin
      ActiveRecord::Base.transaction do
        application.save!
        @validation_trigger.save!

        if data['tableAndFieldRebinds']
          application.rebind_tables_and_fields(data['tableAndFieldRebinds'])
        end
      end
      render_json @validation_trigger.id
    rescue ActiveRecord::RecordInvalid
      render_json @validation_trigger.errors.full_messages.join("\n"), status: 402
    end
  end

  def destroy
    trigger = application.validation_triggers.find params[:id]
    trigger.destroy
    redirect_to application_message_triggers_path(application)
  end

  private

  def load_validation_trigger
    @field_guid = params[:id]
    @validation_trigger = application.validation_triggers.find_by_field_guid @field_guid
    unless @validation_trigger
      @validation_trigger = application.validation_triggers.find_by_id @field_guid
    end
    unless @validation_trigger
      @validation_trigger = application.validation_triggers.new field_guid: @field_guid
    end
    @validation_trigger.application = application
  end
end
