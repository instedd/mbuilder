require "spec_helper"

describe "ElasticQuery" do
  let!(:application) { new_application "users: Age, Name" }
  let(:users) { ElasticRecord.for application.tire_index.name, 'users' }

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
    result.properties[:age].should be(10)
  end

  it "should search for multiple values" do
    results = users.where(age: 20).where(name: 'foo')
    results.count.should be(1)
    result = results.first.properties
    result[:age].should be(20)
    result[:name].should eq('foo')
  end

  it "should retrieve all values" do
    results = users.all
    results.count.should be(4)
    results.to_a.map(&:properties).should include({"age" => 10, "name" =>'foo'})
  end

  it "should retrieve the values sorted" do
    results = users.all.order(age: :desc).order(name: :desc)
    results.to_a.map(&:properties).should eq([
      {"age" => 30, "name" => "bar"},
      {"age" => 20, "name" => "foo"},
      {"age" => 20, "name" => "bar"},
      {"age" => 10, "name" => "foo"}
    ])
  end

  it "should reorder" do
    results = users.all.order(name: :asc).reorder(age: :desc).order(name: :desc)
    results.to_a.map(&:properties).should eq([
      {"age" => 30, "name" => "bar"},
      {"age" => 20, "name" => "foo"},
      {"age" => 20, "name" => "bar"},
      {"age" => 10, "name" => "foo"}
    ])
  end

  it "should paginate" do
    results = users.all.order(name: :asc, age: :asc).page(2).per(3)
    results.count.should be(1)
    results.to_a.map(&:properties).should eq([
      {"age" => 20, "name" => "foo"}
    ])
  end

  it "should inform the correct number of pages" do
    results = users.all.per(3)
    results.total_pages.should be(2)
  end

  it "should iterate through all pages" do
    results = users.all.order(name: :asc, age: :asc).per(2)
    results.count.should be(4)
  end

  it "should allow to update_attributes" do
    result = users.where(age: 10).first
    id = result.id
    result.properties[:age] = 300
    result.save!
    result = users.where(age: 300).first
    result.properties[:age].should be(300)
    result.id.should eq(id)
    result.properties[:age] = 200
    result.save
    result = users.where(age: 200).first
    result.properties[:age].should be(200)
    result.id.should eq(id)
    users.all.count.should be(4)
  end

  it "should allow to create new records" do
    new_user = users.new
    new_user.properties[:age] = 1234
    new_user.properties[:name] = "John Doe"
    new_user.save
    users.all.count.should be(5)
    result = users.where(age: 1234).first
    result.properties[:name].should eq("John Doe")
    result.properties[:age].should eq(1234)
  end

  it "should expose an instance method for each column" do
    user = users.where(age: 10).first
    user.age.should eq(10)
    user.name.should eq('foo')
    user.age = 20
    user.name = 'bar'
    user.age.should eq(20)
    user.name.should eq('bar')
  end

  it "should create a class with the type name in order to be used as an active record model" do
    users
    Users.all.count.should eq(4)
  end

  it "should allow to delete a record" do
    user = users.where(age: 10).first
    user.destroy
    users.where(age: 10).count.should eq(0)
  end
end
