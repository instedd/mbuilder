require 'spec_helper'

describe String do
  describe "to_f_if_looks_like_number" do
    it "should convert negative numbers" do
      "-1".to_f_if_looks_like_number.should be_a(Numeric)
      "-1.5".to_f_if_looks_like_number.should be_a(Numeric)
    end

    it "shouldn't fail for non-numbers" do
      "-".to_f_if_looks_like_number.should be_a(String)
      "-a".to_f_if_looks_like_number.should be_a(String)
      "a".to_f_if_looks_like_number.should be_a(String)
    end
  end
end

