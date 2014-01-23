class ApiController < ApplicationController
  before_filter :authenticate_api_user!

  expose(:application) { current_user.applications.find(params[:id]) }
  expose(:application_table) { application.find_table_by_name(params[:table_id]) || application.find_table(params[:table_id]) }
  expose(:record_class) { ElasticRecord.for(application.tire_index.name, application_table.try(:guid)) }

  def index
    tables = application.local_tables

    # keep access token if used to access api
    url_params = {}
    if params[:access_token]
      url_params[:access_token] = params[:access_token]
    end

    render_json(if params[:schema]
      tables.map { |table| table.as_json.merge url: api_show_url(application.id, table.name, url_params), guid_url: api_show_url(application.id, table.guid, url_params)}
    else
      tables.map do |table|
        {
          'name' => table.name,
          'url'  => api_show_url(application.id, table.name, url_params)
        }
      end
    end)
  end

  def show
    records = if params[:since]
      record_class.where("updated_at >= ?", Time.parse(params[:since]))
    else
      record_class.all
    end

    if params[:guid]
      respond_to do |format|
        format.csv { send_data to_csv(records.map(&:as_json), ['id'].concat(application_table.fields.map &:guid).concat(['created_at', 'updated_at'])), filename: "#{record_class.name}.csv" }
        format.json { render_json records }
      end
    else
      records = records.map do |record|
        hash = {
          'id'         => record.id,
          'created_at' => record.created_at,
          'updated_at' => record.updated_at
        }

        application_table.fields.each do |field|
          hash[field.name] = record.properties[field.guid]
        end
        hash
      end

      respond_to do |format|
        format.csv { send_data to_csv(records, ['id'].concat(application_table.fields.map &:name).concat(['created_at', 'updated_at'])), filename: "#{record_class.name}.csv" }
        format.json { render_json records }
      end
    end
  end

  private

  def to_csv(records, columns)
    CSV.generate do |csv|
      csv << columns
      records.map(&:with_indifferent_access).each do |record|
        csv << columns.map { |c| record[c] }
      end
    end
  end
end
