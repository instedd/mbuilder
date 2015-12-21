require 'spec_helper'

describe ExternalService do
  include_examples 'application lifespan', described_class

  before :each do
    # external service validation
    Net::HTTP.stub(:get)
  end

  it 'should have a guid' do
    ExternalService.new.guid.should_not be_nil
  end

end
