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
        context.set_entity(table, IterationEntity.new(row))
        actions.each do |action|
          action.execute(context)
        end
      end
    end
    context.set_entity(table, entity)
  end
end
