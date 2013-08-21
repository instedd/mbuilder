class TriggersController < ApplicationController
  before_filter :authenticate_user!

  expose(:application) { current_user.applications.find params[:application_id] }
  expose(:triggers) { application.triggers }
  expose(:trigger)

  def create
    set_trigger_data(application.triggers.new)
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
    trigger_data = data['trigger']
    logic_data = data['logic']
    trigger.attributes = trigger_data
    trigger.logic = Logic.new(logic_data)
    trigger.save!

    head :ok
  end
end
