class TablesController < ApplicationController
  before_filter :add_breadcrumbs

  expose(:application)
  expose(:application_table) { application.find_table(params[:table_guid]) if params[:table_guid].present? }

  def import
  end

  def upload
    @importer = Tables::Importer.new current_user, application, application_table
    if params[:file].present? and @importer.save_csv(params[:file])
      @column_specs = @importer.guess_column_specs
    else
      flash.now[:alert] = 'The CSV file is invalid'
      render :import
    end
  end

  def do_import
    @importer = Tables::Importer.new current_user, application, application_table
    @importer.table_name = params[:name] if application_table.blank?
    @importer.column_specs = params[:column_specs]
    if @importer.valid?
      @importer.execute!
      render status: 200, text: 'Import OK'
    else
      render status: 400, text: 'Invalid import column specifications'
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

