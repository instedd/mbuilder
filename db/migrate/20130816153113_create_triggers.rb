class CreateTriggers < ActiveRecord::Migration
  def change
    create_table :triggers do |t|
      t.integer :application_id
      t.string :name

      t.timestamps
    end
  end
end
