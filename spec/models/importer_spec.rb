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

  describe "validation" do
    context "for creating tables" do
      before(:each) do
        @importer = Tables::Importer.new user, application, nil
        @importer.rows = [['foo', 'bar'], ['abc', 123]]
      end

      it "should validate the presence of table name" do
        @importer.should_not be_valid
        @importer.errors[:table_name].should_not be_blank
      end

      it "should validate that the number of column specs and imported columns match" do
        @importer.column_specs = [{action: 'ignore'}]

        @importer.should_not be_valid
        @importer.errors[:base].should_not be_blank
      end
    end

    context "for updating tables" do
      before(:each) do
        @importer = Tables::Importer.new user, application, application.tables.first
        @importer.rows = [['foo', 'bar'], ['abc', 123]]
      end

      it "should allow only one identifier column" do
        @importer.column_specs = [{action: 'existing_identifier', field: 'phone'},
                                  {action: 'existing_identifier', field: 'name'}]

        @importer.should_not be_valid
        @importer.errors[:base].should_not be_blank
      end
    end
  end

  describe "execute!" do
    it "should create a new table" do
      @importer = Tables::Importer.new user, application, nil
      @importer.table_name = "NewTable"
      @importer.rows = [['foo', 'bar'], ['abc', 123]]
      @importer.guess_column_specs!

      @importer.should be_new_table
      lambda do
        result = @importer.execute!
        result[:inserted].should == 1
      end.should change(application.tables, :count).by(1)

      new_table = application.find_table_by_name('NewTable')
      new_table.fields.count.should == 2
      application.elastic_record_for(new_table).count.should == 1
    end

    it "should update existing table" do
      @importer = Tables::Importer.new user, application, application.tables.first
      @importer.rows = [['Name', 'Email'], ['foo', 'a@b.com']]
      @importer.guess_column_specs!

      @importer.should_not be_new_table
      lambda do
        result = @importer.execute!
        result[:inserted].should == 1
      end.should_not change(application.tables, :count)

      @importer.table.fields.count.should == 3
      application.elastic_record_for(@importer.table).count.should == 1
    end

    it "should update records when using an identifier column" do
      table = application.tables.first
      users = application.elastic_record_for table
      users.create [{'phone' => 123.0, 'name' => 'foo'}, {'phone' => 456.0, 'name' => 'bar'}]

      @importer = Tables::Importer.new user, application, table
      @importer.rows = [['Phone', 'Name'], [456, 'quux']]
      col_specs = @importer.guess_column_specs
      col_specs[0][:action] = 'existing_identifier'
      @importer.column_specs = col_specs

      result = @importer.execute!
      result[:inserted].should == 0
      result[:updated].should == 1

      users.count.should == 2
      rows = users.all.to_a.map {|record| [record.properties['phone'], record.properties['name']]}
      rows.sort_by(&:first).should == [[123, 'foo'], [456, 'quux']]
    end
  end
end

