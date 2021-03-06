class Application < ActiveRecord::Base
  attr_accessible :name, :user_id, :time_zone

  belongs_to :user
  has_many :message_triggers, dependent: :destroy
  has_many :external_triggers, dependent: :destroy
  has_many :periodic_tasks, dependent: :destroy
  has_many :validation_triggers, dependent: :destroy
  has_many :channels, dependent: :destroy
  has_many :logs, class_name: :ExecutionLogger, dependent: :destroy
  has_many :external_services, dependent: :destroy
  has_many :external_service_steps, :through => :external_services
  has_many :contacts, dependent: :destroy

  validates_presence_of :user, :name, :time_zone

  after_save :create_index
  after_save :touch_lifespan
  after_destroy :touch_lifespan
  before_destroy :delete_local_index

  serialize :tables

  def tz
    ActiveSupport::TimeZone.new(self.time_zone)
  end

  def accept_message(message)
    Executor.new(self).execute(message)
  end

  def simulate_triggers_execution
    simulate_execution_of message_triggers
  end

  def simulate_execution_of triggers
    context = MemoryExecutionContext.new self, TriggerPlaceholderSolver.new, ExecutionLogger.new(application: self)
    context.execute_many triggers
  end

  def simulate_triggers_execution_excluding trigger
    simulate_execution_of(message_triggers - [trigger])
  end

  def find_external_service_step(guid)
    external_service_steps.includes(:external_service).find_by_guid(guid)
  end

  def find_table(guid)
    table = tables.find { |table| table.guid == guid }
    raise ActiveRecord::RecordNotFound.new("There is no table with id \"#{guid}\"") unless table
    table
  end

  def find_table_by_name(name)
    tables.find { |table| table.name == name }
  end

  def local_index(create_if_not_exists = true)
    index = LocalIndex.new(local_index_name)
    if create_if_not_exists && !index.exists?
      index.create(settings: {
        index: {
          analysis: {
            analyzer: {
              default: {
                tokenizer: :keyword,
                filter: [:lowercase],
                type: :custom,
              }
            }
          }
        }
      })
    end
    index
  end

  def delete_local_index
    local_index.delete
  end

  def create_index
    local_index(true)
  end

  def local_search(table)
    LocalSearch.new local_index, table
  end

  def rebind_tables_and_fields(table_and_field_rebinds)
    all_triggers = message_triggers.all + validation_triggers.all + periodic_tasks.all

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

  def export file
    data = {
      tables: tables,
      message_triggers: message_triggers,
      periodic_tasks: periodic_tasks,
      validation_triggers: validation_triggers,
      external_triggers: external_triggers,
      external_services: external_services.map(&:export)
    }

    file.write data.to_json_oj
  end

  def import! file
    data = JSON.load file

    self.tables = Table.from_list(data["tables"])
    self.message_triggers = MessageTrigger.from_list(data["message_triggers"])
    self.periodic_tasks = PeriodicTask.from_list(data["periodic_tasks"])
    self.validation_triggers = ValidationTrigger.from_list(data["validation_triggers"])
    self.external_triggers = ExternalTrigger.from_list(data["external_triggers"])
    self.external_services = ExternalService.from_list(data["external_services"])

    save!
  end

  def local_tables
    (self.tables || []).select {|table| table.is_a? Tables::Local }
  end

  def elastic_record_for(table)
    ElasticRecord.for(self.local_index.name, table.guid)
  end

  def rebuild_local_tables
    data = {}
    local_tables.each do |table|
      record_class = elastic_record_for(table)
      data[table.guid] = record_class.all.map(&:as_json)
    end

    self.delete_local_index

    local_tables.each do |table|
      # ElasticRecord clases are not catched since index is recreated
      record_class = elastic_record_for(table)
      record_class.create data[table.guid]
    end
  end

  def touch_lifespan
    Telemetry::Lifespan.touch_application(self)
  end

  if Rails.env.test?
    def local_index_name
      "mbuilder_test_application_#{id}"
    end
  else
    def local_index_name
      "mbuilder_application_#{id}"
    end
  end
end
