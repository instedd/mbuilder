class AddTimeZoneToApplications < ActiveRecord::Migration
  def change
    add_column :applications, :time_zone, :string, default: 'UTC'
  end
end
