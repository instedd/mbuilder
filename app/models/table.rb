class Table
  include Hasheable
  subclass_responsibility :fields, :name, :guid

  def find_field(guid)
    fields.find { |field| field.guid == guid }
  end

  def as_json
    {
      name: name,
      guid: guid,
      kind: kind,
      fields: fields.map(&:as_json)
    }
  end
end
