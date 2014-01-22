class ApiController < ApplicationController
  expose(:application)
  expose(:application_table) { application.find_table_by_name(params[:table_id]) || application.find_table(params[:table_id]) }
  expose(:record_class) { ElasticRecord.for(application.tire_index.name, application_table.try(:guid)) }

  def index
    tables = (application.tables || []).select {|table| table.is_a? Tables::Local }
    render_json(if params[:schema]
      tables.map { |table| table.as_json.merge url: api_show_url(application.id, table.name), guid_url: api_show_url(application.id, table.guid)}
    else
      tables.map do |table|
        {
          'name' => table.name,
          'url'  => api_show_url(application.id, table.name)
        }
      end
    end)
  end

  def show
    if params[:guid]
      render_json record_class.all
    else
      records = record_class.all.map do |record|
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
      render_json records
    end
  end
end
