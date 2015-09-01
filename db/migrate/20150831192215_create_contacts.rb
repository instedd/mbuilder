class CreateContacts < ActiveRecord::Migration
  def change
    create_table :contacts do |t|
      t.string :address
      t.references :application

      t.timestamps
    end
  end
end
