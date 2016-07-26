require "json"

namespace :elasticsearch do
  task :export => :environment do
    json_apps = []
    Application.all.each do |application|
      next unless application.tables.present?

      json_app = {
        id: application.id,
        index_nane: application.local_index_name,
      }

      json_tables = []
      application.tables.each do |table|
        next unless table.is_a?(Tables::Local)

        elastic_record = ElasticRecord.for(application.local_index_name, table.guid)
        json_table = {
          guid: table.guid,
          objects: [],
        }
        elastic_record.all.each do |record|
          json_obj = {
            id: record.id,
            properties: record.properties,
            created_at: record.created_at,
            updated_at: record.updated_at,
          }
          json_table[:objects] << json_obj
        end
        next unless json_table[:objects].present?

        json_tables << json_table
      end
      next unless json_tables.present?

      json_app[:tables] = json_tables
      json_apps << json_app
    end
    puts JSON.pretty_generate(json_apps)
  end

  task :import => :environment do
    json_apps = JSON.parse(STDIN.read)
    json_apps.each do |json_app|
      application = Application.find(json_app["id"])
      application.local_index.delete rescue nil
      application.local_index # re-create it
      json_app["tables"].each do |json_table|
        elastic_record = ElasticRecord.for(application.local_index_name, json_table[:guid])
        elastic_record.type = json_table["guid"]

        types = {}
        json_table["objects"].each do |json_obj|
          properties = json_obj["properties"]
          if properties
            properties.each do |key, value|
              if value.to_f_if_looks_like_number.is_a?(Numeric)
                types[key] ||= :number
              else
                types[key] = :string
              end
            end
          end
        end

        json_table["objects"].each do |json_obj|
          rec = elastic_record.new
          rec.id = json_obj["id"]

          properties = json_obj["properties"]

          if properties
            properties = Hash[properties.map do |key, value|
              case types[key]
              when :number
                [key, value.to_f]
              else
                [key, value.nil? ? nil : value.to_s]
              end
            end]
          end

          rec.properties = properties
          rec.created_at = Time.parse(json_obj["created_at"]) if json_obj["created_at"]
          rec.updated_at = Time.parse(json_obj["updated_at"]) if json_obj["updated_at"]
          rec.save!
        end
      end
    end
  end
end
