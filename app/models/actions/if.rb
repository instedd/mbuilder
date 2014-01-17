class Actions::If < Action
  attr_accessor :left
  attr_accessor :op
  attr_accessor :right
  attr_accessor :actions

  def initialize(left, op, right, actions)
    @left = left
    @op = op
    @right = right
    @actions = actions
  end

  def execute(context)
    left_value = left.value_in(context)
    right_values = right.map { |r| r.value_in(context) }

    if Operator.execute(left_value, op, right_values)
      actions.each do |action|
        action.execute(context)
      end
    end
  end

  def as_json
    {
      kind: 'if',
      left: left.as_json,
      op: op,
      right: right.as_json,
      actions: actions.as_json,
    }
  end

  def self.from_hash(hash)
    new Pill.from_hash(hash['left']), hash['op'], Pill.from_list(hash['right']), Action.from_list(hash['actions'])
  end

  class Operator
    def self.execute(left, op, right)
      case op
      when "=="
        to_num(left) == to_num(right.first)
      when "!="
        to_num(left) != to_num(right.first)
      when "contains"
        left.include? right.first
      when ">"
        left.to_f > right.first.to_f
      when "<"
        left.to_f < right.first.to_f
      when "between"
        between(left, right)
      when "not between"
        !between(left, right)
      else
        raise "Uknown op: #{op}"
      end
    end

    def self.between(left, right)
      bottom, top = right.map &:to_f
      left = left.to_f
      bottom <= left && left <= top
    end

    def self.to_num(value)
      Float(value) rescue value
    end
  end
end
