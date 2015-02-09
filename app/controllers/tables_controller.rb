class TablesController < ApplicationController
  before_filter :add_breadcrumbs

  expose(:application)
  expose(:application_table) { application.find_table(params[:table_guid]) if params[:table_guid].present? }

  def upload
    @importer = Tables::Importer.new current_user, application, application_table
    if params[:file].present? and @importer.save_csv(params[:file])
      @column_specs = @importer.guess_column_specs
    else
      flash[:alert] = 'The CSV file is invalid'
      redirect_to application_data_path(application)
    end
  end

  def import
    @importer = Tables::Importer.new current_user, application, application_table
    @importer.table_name = params[:name] if application_table.blank?
    @importer.column_specs = params[:column_specs]
    if @importer.valid?
      result = @importer.execute!
      message = if application_table.blank?
                  "Created table #{@importer.table_name} with #{result[:inserted]} records (#{result[:failed]} failed)"
                else
                  "Imported data into #{@importer.table_name}: #{result[:inserted]} inserts, #{result[:updated]} updates, #{result[:failed]} failed"
                end
      flash.notice = message
      render status: 200, text: message
    else
      render status: 400, json: @importer.errors
    end
  end

  private

  def add_breadcrumbs
    add_breadcrumb 'Applications', :applications_path
    add_breadcrumb application.name, application_path(application)
    add_breadcrumb 'Data', :application_data
    add_breadcrumb 'Import'
  end
end

