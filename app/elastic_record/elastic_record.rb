class ElasticRecord

  class << self
    attr_accessor :index, :type, :client
  end

  attr_accessor :id, :properties

  def initialize
    @properties = {}
  end

  def self.for(index, type)
    table = Class.new(self)
    table.index = index
    table.type = type
    table.client = Elasticsearch::Client.new log: false
    begin
      Object.instance_eval { remove_const(type.camelize) } if const_defined?(type.camelize)
      Object.const_set(type.camelize, table)
    rescue Exception => e
      # The type name is an invalid constant name
    end
    table.columns.each do |column|
      begin
        table.class_eval <<-METHODS, __FILE__, __LINE__ + 1
          def #{column.underscore}
            properties["#{column}"]
          end

          def #{column.underscore}= new_value
            properties["#{column}"] = new_value
          end
        METHODS
      rescue SyntaxError => e
        # The column name was probably a GUID and it doesn't make sense to generate a method
      end
    end
    table
  end

  def self.where(options)
    all.where!(options)
  end

  def self.all
    ElasticQuery.new(self)
  end

  def self.columns
    result = client.indices.get_mapping(index: index, type: type)

    result[type]['properties']['properties']['properties'].keys
  end

  def self.human_attribute_name(name)
    name
  end

  def save!
    self.class.save! self
  end

  def save
    save! rescue false
  end

  def self.save! object
    client.index index: index, type: type, id: object.id, body: {properties: object.properties}, refresh: true
  end

  def destroy
    self.class.destroy self
  end

  def self.destroy object
    client.delete index: index, type: type, id: object.id, refresh: true
  end
end
