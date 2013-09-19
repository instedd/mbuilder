class PeriodicTasksController < TriggersController
  before_filter :authenticate_user!
  before_filter :set_tab

  expose(:application) { current_user.applications.find params[:application_id] }
  expose(:periodic_tasks) { application.periodic_tasks }
  expose(:periodic_task)

  def create
    set_trigger_data(trigger)
  end

  def update
    set_trigger_data(trigger)
  end

  def destroy
    trigger.destroy
    redirect_to application_triggers_path(application)
  end

  private

  def set_trigger_data(trigger)
    data = JSON.parse request.raw_post
    name = data['name']
    actions = data['actions']
    tables = data['tables']
    table_and_field_rebinds = data['tableAndFieldRebinds']

    actions = Action.from_list(actions)
    trigger.name = name
    trigger.logic = ScheduleLogic.new build_schedule_from(data['schedule']), actions

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

  def build_schedule_from data
    schedule = IceCube::Schedule.new(data['time'])

    rule = IceCube::Rule.send(data['granularity'], data['every']) #weekly(2) -> every 2 weeks

    data['onUnit'] ||= 'day'

    rule.send(data['onUnit'], data['on']) #day(:sunday)

    schedule.add_recurrence_rule rule

    schedule
  end
  def set_tab
    @application_tab = :triggers
  end
end
