require "spec_helper"

describe MessagePiece do
  it "infers patter to be single_word" do
    MessagePiece.infer_pattern("John").should eq(:single_word)
  end

  it "infers patter to be multiple_word" do
    MessagePiece.infer_pattern("John Doe").should eq(:multiple_word)
  end

  it "infers patter to be integer" do
    MessagePiece.infer_pattern("123").should eq(:integer)
  end

  it "infers patter to be float" do
    MessagePiece.infer_pattern("123.45").should eq(:float)
  end
end
