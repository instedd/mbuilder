require "spec_helper"
describe "ElasticQuery" do
  let!(:application) { new_application "users: Age, Name" }
  let(:users) { ElasticRecord.new application.tire_name, 'users' }

  before(:each) do
    add_data "users", [
      {"age" => 10, "name" => "foo"},
      {"age" => 20, "name" => "foo"},
      {"age" => 20, "name" => "bar"},
      {"age" => 30, "name" => "bar"},
    ]
  end

  it "should search for a value" do
    result = users.where(age: 10).first
    result[:age].should be(10)
  end

  it "should search for multiple values" do
    results = users.where(age: 20).where(name: 'foo')
    results.count.should be(1)
    result = results.first
    result[:age].should be(20)
    result[:name].should eq('foo')
  end

  it "should retrieve all values" do
    results = users.all
    results.count.should be(4)
    results.to_a.should include({"age" => 10, "name" =>'foo'})
  end

  it "should retrieve the values sorted" do
    results = users.all
    results.count.should be(4)
    results.order(age: :desc).order(name: :desc).to_a.should eq([
      {"age" => 30, "name" => "bar"},
      {"age" => 20, "name" => "foo"},
      {"age" => 20, "name" => "bar"},
      {"age" => 10, "name" => "foo"}
    ])
  end

  it "should reorder" do
    results = users.all
    results.count.should be(4)
    results.order(name: :asc).reorder(age: :desc).order(name: :desc).to_a.should eq([
      {"age" => 30, "name" => "bar"},
      {"age" => 20, "name" => "foo"},
      {"age" => 20, "name" => "bar"},
      {"age" => 10, "name" => "foo"}
    ])
  end
end
