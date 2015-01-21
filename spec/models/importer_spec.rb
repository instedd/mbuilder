require "spec_helper"

describe Tables::Importer do
  let(:user) { User.make }
  let(:application) { new_application "Users: Phone, Name" }

  describe "guess_column_specs" do
    context "for a new table" do
      before(:each) do
        @importer = Tables::Importer.new user, application, nil
      end

      it "returns new field specs for all columns when creating a table" do
        @importer.rows = [['Phone', 'Name'], ['123', 'Foobar']]

        specs = @importer.guess_column_specs
        specs.size.should == 2
        specs[0][:action].should == 'new_field'
        specs[0][:name].should == 'Phone'
        specs[1][:action].should == 'new_field'
        specs[1][:name].should == 'Name'
      end

      it "ignores columns with blank headers" do
        @importer.rows = [['Phone', 'Name', ''], ['123', 'Foobar', nil]]

        specs = @importer.guess_column_specs
        specs.last[:action].should == 'ignore'
      end
    end

    context "for an existing table" do
      before(:each) do
        @table = application.find_table_by_name('Users')
        @importer = Tables::Importer.new user, application, @table
        @importer.rows = [['phone', ' NAME ', 'Email'], ['123', 'Foobar', 'a@b.com']]
      end

      it "returns existing field specs for columns with same name as existing" do
        specs = @importer.guess_column_specs
        specs.size.should == 3
        specs[0][:action].should == 'existing_field'
        specs[0][:field].should == @table.fields[0].guid
        specs[1][:action].should == 'existing_field'
        specs[1][:field].should == @table.fields[1].guid
        specs[2][:action].should == 'new_field'
        specs[2][:name].should == 'Email'
      end
    end
  end
end

