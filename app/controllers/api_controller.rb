class ApiController < ApplicationController
  expose(:application)
  expose(:application_table) { application.find_table(params[:table_id]) }
  expose(:record_class) { ElasticRecord.for(application.tire_index.name, params[:table_id]) }
  expose(:record) do
    if params[:action] == "new" || params[:action] == "create"
      record_class.new params[:record].to_f_if_looks_like_number
    else
      record_class.find(params[:id])
    end
  end

  def index
    render_json (application.tables || []).select {|table| table.is_a? Tables::Local }
  end

  def show
    if params[:guid]
      render_json record_class.all
    else
      records = record_class.all.map do |record|
        hash = Hash.new
        application_table.fields.each do |field|
          hash[field.name] = record.properties[field.guid]
        end
        hash['created_at'] = record.created_at
        hash['updated_at'] = record.updated_at
        hash['id'] = record.id
        hash
      end
      render_json records
    end
  end
end
