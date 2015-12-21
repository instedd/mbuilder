class AddKindToChannels < ActiveRecord::Migration
  def change
    add_column :channels, :kind, :string
  end
end
