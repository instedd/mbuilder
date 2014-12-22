class Table
  include Hasheable
  subclass_responsibility :fields, :name, :guid, :select_field_in, :insert_in

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

  def restrictions_to_properties(restrictions)
    restrictions.each_with_object({}) do |restriction, hash|
      hash[restriction[:field]] = restriction[:value]
    end
  end
end
