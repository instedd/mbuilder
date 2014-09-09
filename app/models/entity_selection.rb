class EntitySelection
  attr_accessor :group_by

  def initialize(context, table, restrictions = [], properties = {}, group_by = nil)
    @context = context
    @table = table
    @restrictions = restrictions
    @properties = properties
    @group_by = group_by
  end

  def table
    @table
  end

  def restrictions
    @restrictions
  end

  def eq(field, value)
    @restrictions.push op: :eq, field: field, value: value
    self
  end

  def []=(field, value)
    @properties[field.to_s] = value
  end

  def field_values(field, aggregate)
    @context.select_table_field(@table, @restrictions, field, group_by, aggregate)
  end

  def each(&block)
    @context.each_value(@table, @restrictions, @group_by, &block)
  end

  def empty?
    self.each { return false }
    true
  end

  def save
    return if @properties.empty?

    @context.update_many(@table, @restrictions, @properties)
  end

  def create_entity_matching_restrictions
    @context.insert(@table, Hash[@restrictions.select { |r| r[:op] == :eq }.map {|r| [r[:field], r[:value].to_single]}])
  end

  def clone
    EntitySelection.new(@context, @table, @restrictions.clone, @properties.clone, @group_by.try(&:clone))
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
