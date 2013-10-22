class ApplicationsController < ApplicationController
  before_filter :authenticate_user!

  expose(:applications) { current_user.applications }
  expose(:application)

  def show
    @application_tab = :overview
  end

  def create
    if application.save
      redirect_to application
    else
      render :new
    end
  end

  def edit
    @application_tab = :settings
  end

  def update
    if application.update_attributes(params[:application])
      redirect_to application
    else
      render :edit
    end
  end

  def destroy
    application.destroy
    redirect_to applications_path
  end

  def data
    @application_tab = :data
    @data = if application.tire_index.exists?
      (application.tables || []).map do |table|
        [table, application.tire_search(table.guid).perform.results.map { |result| result["_source"]["properties"] }]
      end
    else
      []
    end
  end
end
