require "spec_helper"

describe "Tables and fields rebinding" do
  let(:application) { new_application "Users: Phone, Name; Friends: Telephone, DisplayName" }

  before(:each) do
    @trigger = new_trigger do
      message "alert {Name}"
      select_entity "users.name = *name"
      create_entity "users.name = *name"
      store_entity_value "users.name = *name"
      send_message "*phone", "The message: {{message}}"
    end
  end

  it "rebinds tables" do
    application.rebind_tables_and_fields([
      {'kind' => 'table', 'fromTable' => 'users', 'toTable' => 'friends'},
    ])

    @trigger.reload
    actions = @trigger.actions
    actions[0].table.should eq("friends")
    actions[1].table.should eq("friends")
    actions[2].table.should eq("friends")
    actions[3].recipient.guid.should eq("phone")
  end

  it "rebinds fields" do
    application.rebind_tables_and_fields([
      {'kind' => 'field', 'fromField' => 'name', 'toField' => 'display_name'},
      {'kind' => 'field', 'fromField' => 'phone', 'toField' => 'telephone'},
    ])

    @trigger.reload
    actions = @trigger.actions
    actions[0].table.should eq("friends")
    actions[1].field.should eq("display_name")

    actions[1].table.should eq("friends")
    actions[1].field.should eq("display_name")

    actions[2].table.should eq("friends")
    actions[2].field.should eq("display_name")

    actions[3].recipient.guid.should eq("telephone")
  end
end
