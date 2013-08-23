class TriggersController < ApplicationController
  before_filter :authenticate_user!

  expose(:application) { current_user.applications.find params[:application_id] }
  expose(:triggers) { application.triggers }
  expose(:trigger)

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
    message = data['message']
    actions = data['actions']
    tables = data['tables']

    message = Message.from_hash(message)
    actions = Action.from_list(actions)
    trigger.name = name
    trigger.logic = Logic.new message, actions

    application.tables = Table.from_list(tables)

    ActiveRecord::Base.transaction do
      application.save!
      trigger.save!
    end

    render json: trigger.id
  end
end
