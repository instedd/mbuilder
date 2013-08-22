class CreateChannels < ActiveRecord::Migration
  def change
    create_table :channels do |t|
      t.integer :application_id
      t.string :name
      t.string :pigeon_name

      t.timestamps
    end
  end
end
