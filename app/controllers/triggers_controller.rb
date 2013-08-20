class TriggersController < ApplicationController
  expose(:application) { current_user.applications.find params[:application_id] }
  expose(:triggers) { application.triggers }
  expose(:trigger)

  def create
    if trigger.save
      redirect_to application_triggers_path(application)
    else
      render :new
    end
  end

  def update
    if trigger.update_attributes(params[:trigger])
      redirect_to application_triggers_path(application)
    else
      render :edit
    end
  end

  def destroy
    trigger.destroy
    redirect_to application_triggers_path(application)
  end
end
