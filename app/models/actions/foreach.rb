class Actions::Foreach < Action
  attr_accessor :table
  attr_accessor :actions

  def initialize(table, actions)
    @table = table
    @actions = actions
  end

  def execute(context)
    entity = context.entity(table)
    entity.each do |row|
      context.in_subcontext do
        context.set_entity(table, IterationEntity.new(context, entity, row))
        actions.each do |action|
          action.execute(context)
        end
      end
    end
    context.set_entity(table, entity)
  end

  def as_json
    {
      kind: kind,
      table: @table,
      actions: actions.as_json,
    }
  end

  def self.from_hash(hash)
    new hash['table'], Action.from_list(hash['actions'])
  end
end
