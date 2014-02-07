require "spec_helper"

describe "ElasticRecord" do
  let!(:application) { new_application "users: Age, Name" }
  let(:users) { ElasticRecord.for application.tire_index.name, 'users' }

  describe "create" do
    it "should create single object" do
      users.count.should be(0)
      users.create age: 10, name: 'foo'
      users.count.should be(1)

      users.all.first.tap do |u|
        expect(u.properties).to include age: 10
        expect(u.properties).to include name: 'foo'
      end
    end

    it "should create multiple objects" do
      users.count.should be(0)
      users.create [{ age: 10, name: 'foo' }, { age: 20, name: 'bar' }]
      users.count.should be(2)

      users.where(age: 10).first.tap do |u|
        expect(u.properties).to include name: 'foo'
      end

      users.where(age: 20).first.tap do |u|
        expect(u.properties).to include name: 'bar'
      end
    end
  end

  it "records should be able to be copied" do
    users.create [{ age: 10, name: 'foo' }, { age: 20, name: 'bar' }]
    json = users.all.map(&:as_json)

    other_app = new_application "users: Age, Name"
    other_users = ElasticRecord.for other_app.tire_index.name, 'users'

    other_users.create json

    other_users.count.should be(2)
    other_users.where(age: 10).first.tap do |u|
      expect(u.properties).to include name: 'foo'
    end
    other_users.where(age: 20).first.tap do |u|
      expect(u.properties).to include name: 'bar'
    end
  end
end
