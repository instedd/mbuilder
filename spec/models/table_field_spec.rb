require "spec_helper"

describe TableField do
  describe "valid values" do
    let(:table_field) { TableField.new("name", "guid", "2-23, 28,Hello, World") }

    it "checks valid values" do
      table_field.valid_value?("1").should be_false

      table_field.valid_value?("2").should be_true
      table_field.valid_value?(2).should be_true

      table_field.valid_value?("8").should be_true
      table_field.valid_value?(8).should be_true

      table_field.valid_value?("28").should be_true
      table_field.valid_value?(28).should be_true

      table_field.valid_value?(29).should be_false
      table_field.valid_value?(29).should be_false

      table_field.valid_value?("Hello").should be_true
      table_field.valid_value?("World").should be_true
      table_field.valid_value?("Bye").should be_false
    end
  end
end
