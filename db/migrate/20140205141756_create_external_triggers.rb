class CreateExternalTriggers < ActiveRecord::Migration
  def change
    create_table :external_triggers do |t|
      t.references :application
      t.string :name
      t.text :actions
      t.text :route

      t.timestamps
    end
    add_index :external_triggers, :application_id
  end
end
