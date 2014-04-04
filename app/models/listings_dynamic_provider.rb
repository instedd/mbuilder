module Listings
  module ActionViewExtensions
    def lookup_listing_class(name)
      if name.to_s =~ /^es__(.*)__(.*)__(.*)$/
        # TODO, restrict security

        application_id = $1
        index = $2
        type = $3

        application = Application.find(application_id)
        table = application.find_table(type)
        elastic_record = ElasticRecord.for(index, type)

        listing_class = Class.new(Listings::Base)
        listing_class.css_class 'graygrad'

        listing_class.send(:define_method, :name, lambda { |*args| name })

        listing_class.send(:define_method, :has_active_model_source?, lambda { |*args| true })

        listing_class.export :csv, :xls

        listing_class.model do
          elastic_record.all
        end

        table.fields.each do |app_field|
          listing_class.column app_field.name, sortable: app_field.guid do |item|
            item.properties[app_field.guid].try(:user_friendly)
          end
        end

        listing_class.column '', class: 'right' do |record|
          [
            link_to("edit", edit_application_table_record_path(application_id, type, record.id)),
            link_to("delete", application_table_record_path(application_id, type, record.id), method: :delete, confirm: "Are you sure you want to delete the record?")
          ].join(' ').html_safe if format == :html
        end

        listing_class
      else
        "#{name}_listing".classify.constantize
      end
    end
  end
end
