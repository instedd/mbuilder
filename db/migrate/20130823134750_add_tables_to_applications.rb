class AddTablesToApplications < ActiveRecord::Migration
  def change
    add_column :applications, :tables, :text
  end
end
