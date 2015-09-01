class AddLastIncomingAtToContacts < ActiveRecord::Migration
  def change
    add_column :contacts, :last_incoming_at, :datetime
  end
end
