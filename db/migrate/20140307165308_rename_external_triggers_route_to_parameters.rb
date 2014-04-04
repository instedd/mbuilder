class RenameExternalTriggersRouteToParameters < ActiveRecord::Migration
  def change
    change_table :external_triggers do |t|
      t.rename :route, :parameters
    end
  end
end
