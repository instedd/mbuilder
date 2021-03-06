class ElasticRecord
  class << self
    attr_accessor :index, :type, :client
  end

  include ActiveModel::Validations

  attr_accessor :id, :properties, :created_at, :updated_at, :_source


  def initialize(*attributes)
    @properties = if attributes.first.is_a? Hash
      attributes.first
    else
      {}
    end
  end

  def self.for(index, type)
    table = Class.new(self)
    table.index = index
    table.type = type
    table.client = Elasticsearch::Client.new log: false

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

  def self.where(*options)
    all.where!(*options)
  end

  def self.find(*ids)
    results = where(id: ids.flatten)
    results = results.first if results.count == 1
    results
  rescue Elasticsearch::Transport::Transport::Errors::NotFound => e
    raise ActiveRecord::RecordNotFound.new e.message
  end

  def self.find_by_id(*ids)
    find ids
  end

  def self.all
    ElasticQuery.new(self)
  end

  def self.count
    self.all.count
  end

  # {"31f8f311-137a-4ba4-b696-853a96e279a2"=>{"type"=>"double"},
  #  "54e9ba76-7003-4654-9bc9-c3e176a23b57"=>{"type"=>"string"}
  # }
  def self.properties_mapping
    client.indices.refresh index: index
    begin
      result = client.indices.get_mapping(index: index, type: type)
      result[index]['mappings'][type]['properties']['properties']['properties'] || {} rescue {}
    rescue Elasticsearch::Transport::Transport::Errors::NotFound => e
      {}
    end
  end

  def self.columns
    self.properties_mapping.keys
  end

  def self.human_attribute_name(name, options = {})
    name
  end

  def persisted?
    !id.nil?
  end

  def save!
    self.class.save! self
  end

  def save
    save! rescue false
  end

  def update_attributes!(attributes)
    properties.merge! attributes
    save!
  end

  def update_attributes(attributes)
    properties.merge! attributes
    save
  end

  def self.save! object
    if object.invalid?
      throw ActiveRecord::RecordInvalid.new(object)
    end
    updated_at = Time.now
    created_at = object.created_at || updated_at
    begin
      response = client.index index: index, type: type, id: object.id, body: {properties: object.properties, created_at: created_at.utc.iso8601, updated_at: updated_at.utc.iso8601}, refresh: true
      object.created_at = created_at
      object.updated_at = updated_at
      object.id = response["_id"]
    rescue
    end
    object
  end

  def self.create(objects)
    objects = [objects] unless objects.kind_of?(Array)
    objects.map { |o| self.new(o) }.each &:save!
  end

  def destroy
    self.class.destroy self
  end

  def self.destroy object
    client.delete index: index, type: type, id: object.id, refresh: true
  end

  def as_json
    { id: id, created_at: created_at, updated_at: updated_at }.merge properties
  end

  validate do
    values = self.properties.with_indifferent_access
    self.class.properties_mapping.each do |column, mapping|
      value = values[column]
      if (mapping["type"] == "double" && !(value.is_a?(Float) || value.is_a?(Fixnum))) or
         (mapping["type"] == "long" && !value.is_a?(Fixnum))
        # nil numbers are empty strings
        unless value.nil? || (value.is_a?(String) && value.blank?)
          errors.add(column, "must be a number")
        end
      end
    end
  end
end
