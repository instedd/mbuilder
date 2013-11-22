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
        elastic_record = ElasticRecord.new(index, type)

        listing_class = Class.new(Listings::Base)
        listing_class.send(:define_method, :name, lambda { |*args| name })
        listing_class.paginates_per 1
        listing_class.model do
          elastic_record.all
        end

        table.fields.each do |app_field|
          listing_class.column app_field.name do |item|
            item[app_field.guid]
          end
        end

        listing_class
      else
        "#{name}_listing".classify.constantize
      end
    end
  end
end
