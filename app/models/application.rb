class Application < ActiveRecord::Base
  attr_accessible :name, :user_id

  belongs_to :user
  has_many :triggers, dependent: :destroy
  has_many :channels, dependent: :destroy

  validates_presence_of :user
  validates_presence_of :name

  serialize :tables

  def accept_message(message)
    Executor.new(self).execute(message)
  end

  def find_table(guid)
    tables.find { |table| table.guid == guid }
  end

  def tire_index
    index = Tire::Index.new(tire_name)
    index.create unless index.exists?
    index
  end

  def tire_search(table)
    Tire::Search::Search.new tire_index.name, type: table
  end

  def rebind_tables_and_fields(table_and_field_rebinds)
    triggers = self.triggers.all
    triggers.each do |trigger|
      table_and_field_rebinds.each do |rebind|
        case rebind['kind']
        when 'table'
          trigger.rebind_table(rebind['fromTable'], rebind['toTable'])
        when 'field'
          trigger.rebind_field(rebind['fromField'], table_of(rebind['toField']).guid, rebind['toField'])
        end
      end
    end
    triggers.each(&:save!)
  end

  def table_of field_guid
    tables.detect(proc{raise "Table not found for #{field_guid} #{tables}"}) do |table|
      table.fields.any? do |field|
        field.guid == field_guid
      end
    end
  end

  if Rails.env.test?
    def tire_name
      "mbuilder_test_application_#{id}"
    end
  else
    def tire_name
      "mbuilder_application_#{id}"
    end
  end
end
