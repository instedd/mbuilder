class CreateValidationTriggers < ActiveRecord::Migration
  def change
    create_table :validation_triggers do |t|
      t.integer :application_id
      t.string :field_guid
      t.text :logic

      t.timestamps
    end
  end
end
