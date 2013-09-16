class EntitySelection
  def initialize(context, table)
    @context = context
    @table = table
    @restrictions = []
    @properties = {}
  end

  def eq(field, value)
    @restrictions.push op: :eq, field: field, value: value
    self
  end

  def []=(field, value)
    @properties[field.to_s] = value
  end

  def field_values(field)
    @context.select_table_field(@table, @restrictions, field)
  end

  def save
    return if @properties.empty?

    @context.update_many(@table, @restrictions, @properties)
  end

  def to_s
    str = "select #{@table}"
    if @restrictions.present?
      str << " where "
      @restrictions.each_with_index do |res, i|
        str << " and " if i > 0
        case res[:op]
        when :eq
          str << "#{res[:field]} = #{res[:value]}"
        end
      end
    end
    str
  end
end
