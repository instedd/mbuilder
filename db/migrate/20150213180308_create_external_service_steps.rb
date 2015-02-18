class CreateExternalServiceSteps < ActiveRecord::Migration
  def change
    create_table :external_service_steps do |t|
      t.references :external_service
      t.string :name
      t.string :display_name
      t.string :icon
      t.string :callback_url
      t.text :variables
      t.string :response_type
      t.text :response_variables
      t.string :guid

      t.timestamps
    end
    add_index :external_service_steps, :external_service_id
  end
end
