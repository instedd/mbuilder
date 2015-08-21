module Listings
  module ActionViewExtensions
    class ElasticRecordDataSource < Listings::Sources::DataSource
      attr_reader :elastic_record

      def initialize(elastic_record)
        @elastic_record = elastic_record
        @items = elastic_record.all
      end

      def items
        @items
      end

      def paginate(page, page_size)
        @items = @items.page(page).per(page_size)
      end

      def sort_with_direction(field, direction)
        @items = field.sort @items, direction
      end

      def build_field(path)
        ElasticRecordField.new(path, self)
      end

      class ElasticRecordField < Listings::Sources::Field
        def initialize(path, data_source)
          super(data_source)
          @path = path
        end

        def value_for(item)
          item.properties[@path]
        end

        def key
          @path.to_s
        end

        def human_name
          @path.to_s
        end

        def sort(items, direction)
          items.reorder("#{@path} #{direction}")
        end
      end
    end

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

        listing_class.export :csv, :xls

        listing_class.model do
          ElasticRecordDataSource.new(elastic_record)
        end

        table.fields.each do |app_field|
          listing_class.column app_field.guid.to_sym, title: app_field.name do |item, field_value|
            field_value.try(:user_friendly)
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
