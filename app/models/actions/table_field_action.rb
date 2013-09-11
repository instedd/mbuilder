module Actions::TableFieldAction
  # TODO Change this into an abstract class with classic inheritance
  extend ActiveSupport::Concern

  included do
    attr_accessor :pill
    attr_accessor :table
    attr_accessor :field
  end

  def initialize(table, field, pill)
    @table = table
    @field = field
    @pill = pill
  end

  def rebind_table(from_table, to_table)
    @table = to_table if @table == from_table
  end

  def rebind_field(from_field, to_table, to_field)
    if @field == from_field
      @table = to_table
      @field = to_field
    end
  end

  def as_json
    {
      kind: kind,
      table: table,
      field: field,
      pill: pill.as_json,
    }
  end

  module ClassMethods
    def from_hash(hash)
      new hash['table'], hash['field'], Pill.from_hash(hash['pill'])
    end
  end
end
