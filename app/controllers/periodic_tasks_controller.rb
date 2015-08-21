class PeriodicTasksController < MbuilderApplicationController
  before_filter do
    add_breadcrumb 'Triggers', application_message_triggers_path(application)
  end
  layout "trigger_edit"
  set_application_tab :triggers

  expose(:periodic_tasks) { application.periodic_tasks }
  expose(:periodic_task)

  def create
    set_periodic_task_data(periodic_task)
  end

  def edit
    add_breadcrumb periodic_task.name, application_periodic_task_path(application, periodic_task)
  end

  def update
    set_periodic_task_data(periodic_task)
  end

  def destroy
    periodic_task.destroy
    redirect_to application_message_triggers_path(application)
  end

  def new
    add_breadcrumb 'New periodic task'
  end

  private

  def set_periodic_task_data(periodic_task)
    data = JSON.parse request.raw_post

    periodic_task.name = data['name']
    periodic_task.enabled = data['enabled']
    periodic_task.actions = Action.from_list(data['actions'])
    periodic_task.update_schedule_with IceCube::Rule.from_hash(JSON.parse data['schedule']), application.tz.parse(data['scheduleTime'])

    application.tables = Table.from_list data['tables']

    begin
      ActiveRecord::Base.transaction do
        application.save!
        periodic_task.save!

        if data['tableAndFieldRebinds']
          application.rebind_tables_and_fields(data['tableAndFieldRebinds'])
        end
      end
      render_json periodic_task.id
    rescue ActiveRecord::RecordInvalid
      render_json periodic_task.errors.full_messages.join("\n"), status: 402
    end
  end
end
