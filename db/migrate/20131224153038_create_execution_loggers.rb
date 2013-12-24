class CreateExecutionLoggers < ActiveRecord::Migration
  def change
    create_table :execution_loggers do |t|
      t.references :application
      t.text :actions
      t.string :message
      t.string :sender
      t.references :trigger

      t.timestamps
    end
    add_index :execution_loggers, :application_id
    add_index :execution_loggers, :trigger_id
  end
end
