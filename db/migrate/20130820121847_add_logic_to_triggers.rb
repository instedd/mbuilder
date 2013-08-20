class AddLogicToTriggers < ActiveRecord::Migration
  def change
    add_column :triggers, :logic, :text
  end
end
