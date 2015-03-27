require 'spec_helper'

describe ExternalServiceStep do
  let(:step) do
    ExternalServiceStep.new.tap do |s|
      s.name = 'step name'
    end
  end

  it 'should be valid' do
    step.should be_valid
  end

  it 'should have a guid' do
    step.guid.should_not be_nil
  end

  it 'should validate variables' do
    step.variables  = [ExternalServiceStep::Variable.new('123foo')]

    step.should be_invalid
  end

  it 'should tell absolute url using callback' do
    service = ExternalService.new

    step.callback_url = '/step_callback'
    step.external_service = service

    service.should_receive(:to_absolute_url).with(step.callback_url).and_return('http://foo.com/step_callback')

    step.absolute_callback_url.should eq('http://foo.com/step_callback')
  end
end
