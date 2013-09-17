class Pills::FieldValuePill < Pill
  attr_reader :guid
  attr_reader :fun

  def initialize(guid, fun)
    @guid = guid
    @fun = fun
  end

  def value_in(context)
    values = Array(context.entity_field_values(guid))
    case fun
    when 'count'
      values.length
    when 'sum'
      to_num values.sum(&:to_f)
    when 'avg'
      sum = values.sum(&:to_f)
      len = values.length
      to_num(len == 0 ? 0 : sum / len)
    when 'max'
      to_num values.map(&:to_f).max
    when 'min'
      to_num values.map(&:to_f).min
    else
      values.join ", "
    end
  end

  def rebind_table(from_table, to_table)
    # nothing to do?
  end

  def rebind_field(from_field, to_table, to_field)
    @guid = to_field
  end

  def self.from_hash(hash)
    new hash['guid'], hash['fun']
  end

  def to_num(num)
    num = num.to_i if num.to_i == num.to_f
    num
  end

  def as_json
    {
      kind: kind,
      guid: guid,
      fun: fun,
    }
  end
end
