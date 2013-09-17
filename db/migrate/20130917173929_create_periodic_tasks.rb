class CreatePeriodicTasks < ActiveRecord::Migration
  def change
    create_table :periodic_tasks do |t|
      t.integer :application_id
      t.string :name
      t.text :logic

      t.timestamps
    end
  end
end
