require 'spec_helper'

describe ExternalService do

  it 'should have a guid' do
    ExternalService.new.guid.should_not be_nil
  end

end
