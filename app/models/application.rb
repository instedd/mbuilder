class Application < ActiveRecord::Base
  attr_accessible :name, :user_id

  belongs_to :user
  has_many :triggers, dependent: :destroy
  has_many :periodic_tasks, dependent: :destroy
  has_many :validation_triggers, dependent: :destroy
  has_many :channels, dependent: :destroy

  validates_presence_of :user
  validates_presence_of :name

  serialize :tables

  def accept_message(message)
    Executor.new(self).execute(message)
  end

  def simulate_triggers_execution
    simulate_execution_of triggers
  end

  def simulate_execution_of triggers
    context = MemoryExecutionContext.new self, TriggerPlaceholderSolver.new
    context.execute_many triggers
  end

  def simulate_triggers_execution_excluding trigger
    simulate_execution_of(triggers - [trigger])
  end

  def find_table(guid)
    tables.find { |table| table.guid == guid }
  end

  def tire_index(create_if_not_exists = true)
    index = Tire::Index.new(tire_name)
    index.create if create_if_not_exists && !index.exists?
    index
  end

  def tire_search(table)
    Tire::Search::Search.new tire_index.name, type: table
  end

  def rebind_tables_and_fields(table_and_field_rebinds)
    all_triggers = triggers.all + validation_triggers.all + periodic_tasks.all

    table_and_field_rebinds.each do |rebind|
      case rebind['kind']
      when 'table'
        from_table = rebind['fromTable']
        to_table = rebind['toTable']
        all_triggers.each { |trigger| trigger.rebind_table from_table, to_table }
      when 'field'
        from_field = rebind['fromField']
        to_table = table_of(rebind['toField']).guid
        to_field = rebind['toField']
        all_triggers.each { |trigger| trigger.rebind_field from_field, to_table, to_field }
      end
    end

    all_triggers.each(&:save!)
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
