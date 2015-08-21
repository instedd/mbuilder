class CreateExternalServices < ActiveRecord::Migration
  def change
    create_table :external_services do |t|
      t.references :application
      t.string :name
      t.string :url
      t.text :data
      t.text :global_settings
      t.string :guid
      t.string :base_url

      t.timestamps
    end
    add_index :external_services, :application_id
  end
end
