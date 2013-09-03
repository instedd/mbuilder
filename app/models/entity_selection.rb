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
    @context.select_table_field(@table, field) do |search|
      apply_search_restrictions(search)
    end
  end

  def save
    @context.update_many(@table, @properties) do |search|
      apply_search_restrictions(search)
    end
  end

  def apply_search_restrictions(search)
    @restrictions.each do |restriction|
      search.query do
        case restriction[:op]
        when :eq
          values = Array(restriction[:value])
          boolean do
            values.each do |value|
              should { match restriction[:field], value }
            end
          end
        end
      end
    end
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
