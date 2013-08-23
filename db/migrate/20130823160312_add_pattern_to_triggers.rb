class AddPatternToTriggers < ActiveRecord::Migration
  def change
    add_column :triggers, :pattern, :string
  end
end
