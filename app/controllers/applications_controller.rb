class ApplicationsController < ApplicationController
  before_filter :authenticate_user!

  expose(:applications) { current_user.applications }
  expose(:application)

  def create
    if application.save
      redirect_to applications_path
    else
      render :new
    end
  end

  def update
    if application.update_attributes(params[:application])
      redirect_to applications_path
    else
      render :edit
    end
  end

  def destroy
    application.destroy
    redirect_to applications_path
  end

  def data
    @data = application.tables.map do |table|
      results = application.tire_search(table.guid).perform.results
      properties = results.map { |result| result["_source"]["properties"] }
      [table, properties]
    end
  end
end
