class AddLastOutgoingAtToContacts < ActiveRecord::Migration
  def change
    add_column :contacts, :last_outgoing_at, :datetime
  end
end
