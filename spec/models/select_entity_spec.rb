require "spec_helper"

describe "Select entity" do
  let(:application) { new_application "Users: Phone, Name; Tags: Keyword; Members: User, Tag" }

  before(:each) do
    new_trigger do
      message "register {John}"
      create_entity "users.phone = {phone_number}"
      store_entity_value "users.name = {john}"
    end

    new_trigger do
      message "tag {Blue} {John}"

      # save tag if there is not one already
      select_entity "tags.keyword = {blue}"
      if_all("*keyword != {blue}") do
        create_entity "tags.keyword = {blue}"
      end

      create_entity "members.user = {john}"
      store_entity_value "members.tag = {blue}"
    end

    new_trigger do
      message "alert {Blue}"
      select_entity "tags.keyword = {blue}"
      select_entity "members.tag = {blue}"
      select_entity "users.name = *user"
      send_message "*phone", "{*keyword}" # use stored tag value
    end
  end

  it "should select many" do
    accept_message "sms://1111", "register John"
    accept_message "sms://2222", "register Sally"
    accept_message "sms://3333", "register George"
    accept_message "sms://4444", "tag Blue John"
    accept_message "sms://4444", "tag Blue Sally"

    ctx = accept_message "sms://4444", "alert Blue"

    ctx.messages.should include({from: "app://mbuilder", to: "sms://1111", body: "Blue", :"mbuilder-application" => application.id})
    ctx.messages.should include({from: "app://mbuilder", to: "sms://2222", body: "Blue", :"mbuilder-application" => application.id})
    ctx.messages.count.should eq(2)
  end

  it "should select case insensitive" do
    accept_message "sms://1111", "register John"
    accept_message "sms://2222", "register Sally"
    accept_message "sms://3333", "register George"
    accept_message "sms://4444", "tag Blue John"
    accept_message "sms://4444", "tag Blue Sally"

    ctx = accept_message "sms://4444", "alert blue"

    ctx.messages.should include({from: "app://mbuilder", to: "sms://1111", body: "Blue", :"mbuilder-application" => application.id})
    ctx.messages.should include({from: "app://mbuilder", to: "sms://2222", body: "Blue", :"mbuilder-application" => application.id})
    ctx.messages.count.should eq(2)
  end

  it "should select by many fields and value" do
    accept_message "sms://1111", "register John"
    accept_message "sms://1111", "register Sally"
    accept_message "sms://1111", "register George"
    accept_message "sms://2222", "register George"
    accept_message "sms://3333", "register John"

    accept_message "sms://4444", "tag Blue John"
    accept_message "sms://4444", "tag Blue Sally"
    accept_message "sms://4444", "tag Red John"
    accept_message "sms://4444", "tag Red George"

    new_trigger do
      message "find {Blue} {1111}"
      select_entity "members.tag = {blue}"
      select_entity "users.name = *user"
      select_entity "users.phone = {1111}"
      send_message "{phone_number}", "{*count(name)}" # use stored tag value
    end

    ctx = accept_message "sms://5555", "find blue 1111"

    ctx.messages.should include({from: "app://mbuilder", to: "sms://5555", body: "2", :"mbuilder-application" => application.id})
    ctx.messages.count.should eq(1)
  end
end
