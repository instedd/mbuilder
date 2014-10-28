class AddAuthMethodToExternalTriggers < ActiveRecord::Migration
  def change
    add_column :external_triggers, :auth_method, :string
  end
end
