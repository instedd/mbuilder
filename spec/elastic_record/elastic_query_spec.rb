require "spec_helper"

describe "ElasticQuery" do
  let!(:application) { new_application "users: Age, Name" }
  let(:users) { ElasticRecord.for application.local_index.name, 'users' }

  before(:each) do
    Timecop.freeze(Time.utc(2013, 9, 17, 6, 0, 0))
    add_data "users", [
      {"age" => 10, "name" => "foo"},
      {"age" => 20, "name" => "foo"},
      {"age" => 20, "name" => "bar"},
      {"age" => 30, "name" => "bar"},
    ]
    (Elasticsearch::Client.new log: false).indices.refresh index: application.local_index.name
  end

  after(:each) { Timecop.return }

  it "should search for a value" do
    result = users.where(age: 10).first
    result.properties[:age].should be(10.0)
  end

  it "should search for multiple values" do
    results = users.where(age: 20, name: 'foo')
    results.count.should be(1)
    result = results.first.properties
    result[:age].should be(20.0)
    result[:name].should eq('foo')
  end

  it "should retrieve all values" do
    results = users.all
    results.count.should be(4)
    results.to_a.map(&:properties).should include({"age" => 10, "name" =>'foo'})
  end

  it "should retrieve the values sorted" do
    results = users.all.order("age desc").order("name desc")
    results.to_a.map(&:properties).should eq([
      {"age" => 30, "name" => "bar"},
      {"age" => 20, "name" => "foo"},
      {"age" => 20, "name" => "bar"},
      {"age" => 10, "name" => "foo"}
    ])
  end

  it "should reorder" do
    results = users.all.order("name asc").reorder("age desc").order("name desc")
    results.to_a.map(&:properties).should eq([
      {"age" => 30, "name" => "bar"},
      {"age" => 20, "name" => "foo"},
      {"age" => 20, "name" => "bar"},
      {"age" => 10, "name" => "foo"}
    ])
  end

  it "should paginate" do
    results = users.all.order("name asc", "age asc").page(2).per(3)
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
    results = users.all.order("name asc", "age asc").per(2)
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

  it "should set and update created_at and updated_at when saving" do
    result = users.new
    result.properties[:age] = 234
    result.properties[:name] = 'baz'
    result.save!
    result.created_at.should eq(Time.now)
    result.updated_at.should eq(Time.now)

    result = users.where(age: 234).first
    result.created_at.should eq(Time.now)
    result.updated_at.should eq(Time.now)
    Timecop.return
    Timecop.freeze(Time.utc(2013, 9, 17, 7, 0, 0))
    result.properties[:name] = 'zoo'
    result.save!
    result.created_at.should eq(Time.utc(2013, 9, 17, 6, 0, 0))
    result.updated_at.should eq(Time.now)

    result = users.where(age: 234).first
    result.created_at.should eq(Time.utc(2013, 9, 17, 6, 0, 0))
    result.updated_at.should eq(Time.now)
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

  it "should allow to delete a record" do
    user = users.where(age: 10).first
    user.destroy
    users.where(age: 10).count.should eq(0)
  end

  it "should allow to find an element by id" do
    id = users.where(age: 10).first.id
    id2 = users.where(age: 30).first.id

    result = users.find(id)
    result.id.should eq(id)
    result.age.should eq(10)
    result.name.should eq("foo")

    results = users.find(id, id2)
    results.first.id.should eq(id)
    results.first.age.should eq(10)
    results.first.name.should eq("foo")
    results.last.id.should eq(id2)
    results.last.age.should eq(30)
    results.last.name.should eq("bar")

    result = users.find_by_id(id)
    result.id.should eq(id)
    result.age.should eq(10)
    result.name.should eq("foo")

    results = users.find_by_id(id, id2)
    results.first.id.should eq(id)
    results.first.age.should eq(10)
    results.first.name.should eq("foo")
    results.last.id.should eq(id2)
    results.last.age.should eq(30)
    results.last.name.should eq("bar")

    result = users.where(id: id).first
    result.id.should eq(id)
    result.age.should eq(10)
    result.name.should eq("foo")

    results = users.where(id: [id, id2])
    results.first.id.should eq(id)
    results.first.age.should eq(10)
    results.first.name.should eq("foo")
    results.last.id.should eq(id2)
    results.last.age.should eq(30)
    results.last.name.should eq("bar")
  end

  it "should filter by >= with a query parameter" do
    add_data "users", [
      {"age" => 10, "name" => "foo2"},
      {"age" => 20, "name" => "foo3"},
      {"age" => 20, "name" => "bar2"},
      {"age" => 30, "name" => "bar3"},
    ]

    results = users.where('age >= ?', 20).order("age desc").order("name desc")
    results.to_a.map(&:properties).should eq([
      {"age" => 30, "name" => "bar3"},
      {"age" => 30, "name" => "bar"},
      {"age" => 20, "name" => "foo3"},
      {"age" => 20, "name" => "foo"},
      {"age" => 20, "name" => "bar2"},
      {"age" => 20, "name" => "bar"}
    ])
  end

  it "should filter by >= with a fixed query string" do
    add_data "users", [
      {"age" => 10, "name" => "foo2"},
      {"age" => 20, "name" => "foo3"},
      {"age" => 20, "name" => "bar2"},
      {"age" => 30, "name" => "bar3"},
    ]
    (Elasticsearch::Client.new log: false).indices.refresh index: application.local_index.name

    results = users.where('age >= 20').order("age desc").order("name desc")
    results.to_a.map(&:properties).should eq([
      {"age" => 30, "name" => "bar3"},
      {"age" => 30, "name" => "bar"},
      {"age" => 20, "name" => "foo3"},
      {"age" => 20, "name" => "foo"},
      {"age" => 20, "name" => "bar2"},
      {"age" => 20, "name" => "bar"}
    ])
  end

    it "should filter a string property by >=" do
    add_data "users", [
      {"age" => 10, "name" => "foo2"},
      {"age" => 20, "name" => "foo3"},
      {"age" => 20, "name" => "bar2"},
      {"age" => 30, "name" => "bar3"},
    ]
    (Elasticsearch::Client.new log: false).indices.refresh index: application.local_index.name

    results = users.where('name >= foo').order("age desc").order("name desc")
    results.to_a.map(&:properties).should eq([
      {"age"=>20.0, "name"=>"foo3"},
      {"age"=>20.0, "name"=>"foo"},
      {"age"=>10.0, "name"=>"foo2"},
      {"age"=>10.0, "name"=>"foo"}
    ])
  end

  it "should filter created_at by >=" do
    Timecop.return
    Timecop.freeze(Time.utc(2013, 9, 18, 7, 0, 0))
    add_data "users", [
      {"age" => 10, "name" => "foo2"},
      {"age" => 20, "name" => "foo3"},
      {"age" => 20, "name" => "bar2"},
      {"age" => 30, "name" => "bar3"},
    ]
    (Elasticsearch::Client.new log: false).indices.refresh index: application.local_index.name

    results = users.where('created_at >= ?', Time.utc(2013, 9, 17, 6, 30, 0)).order("age desc").order("name desc")
    results.to_a.map(&:properties).should eq([
      {"age" => 30, "name" => "bar3"},
      {"age" => 20, "name" => "foo3"},
      {"age" => 20, "name" => "bar2"},
      {"age" => 10, "name" => "foo2"}
    ])
  end
end
