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
        listing_class.send(:define_method, :name, lambda { |*args| name })

        listing_class.send(:define_method, :has_active_model_source?, lambda { |*args| true })

        listing_class.export :csv, :xls

        listing_class.model do
          elastic_record.all
        end

        table.fields.each do |app_field|
          listing_class.column app_field.name do |item|
            item[app_field.guid].try(:user_friendly)
          end
        end

        # listing_class.column '', class: 'right' do |trigger|
        #   [
        #     link_to("edit", edit_application_message_trigger_path(@application, trigger)),
        #     link_to("delete", [@application, trigger], method: :delete, confirm: "Are you sure you want to delete the trigger '#{trigger.name}'")
        #   ].join(' ').html_safe
        # end

        listing_class
      else
        "#{name}_listing".classify.constantize
      end
    end
  end
end
