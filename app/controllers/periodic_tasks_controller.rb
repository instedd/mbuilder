class PeriodicTasksController < ApplicationController
  before_filter :authenticate_user!
  before_filter :set_tab

  expose(:application) { current_user.applications.find params[:application_id] }
  expose(:periodic_tasks) { application.periodic_tasks }
  expose(:periodic_task)

  def create
    set_periodic_task_data(periodic_task)
  end

  def update
    set_periodic_task_data(periodic_task)
  end

  def destroy
    periodic_task.destroy
    redirect_to application_periodic_tasks_path(application)
  end

  private

  def set_periodic_task_data(periodic_task)
    data = JSON.parse request.raw_post
    name = data['name']
    actions = data['actions']
    tables = data['tables']
    table_and_field_rebinds = data['tableAndFieldRebinds']

    actions = Action.from_list(actions)
    periodic_task.name = name

    periodic_task.updateRule IceCube::Rule.from_hash(JSON.parse data['schedule']), Time.parse(data['scheduleTime'])

    periodic_task.logic = ScheduleLogic.new actions

    application.tables = Table.from_list(tables)

    begin
      ActiveRecord::Base.transaction do
        application.save!
        periodic_task.save!

        if table_and_field_rebinds
          application.rebind_tables_and_fields(table_and_field_rebinds)
        end
      end
      render json: periodic_task.id
    rescue ActiveRecord::RecordInvalid
      render json: periodic_task.errors.full_messages.join("\n"), status: 402
    end
  end

  def set_tab
    @application_tab = :triggers
  end
end
