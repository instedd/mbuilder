require 'spec_helper'

describe ExternalServiceParser do

  let(:service) { ExternalService.new(url: 'www.foo.com') }
  let(:parser) { ExternalServiceParser.new(service) }

  it 'should return service' do
    parser.parse('{}').should eq(service)
  end

  it 'should parse service name' do
    data = {name: 'service name'}.to_json

    parser.parse data

    service.name.should eq('service name')
  end

  describe 'global settings' do
    let(:global_settings) do
      {
        variables: [
          {'name' => 'foo', 'display_name' => 'Foo Var'},
          {'name' => 'bar', 'display_name' => 'Bar Var'}
        ]
      }
    end

    it 'should keep global settings empty if definition not present' do
      data = {name: 'service name'}.to_json

      parser.parse data

      service.global_settings.should eq({})
    end

    it 'should keep global variales empty if definition not present' do
      data = {name: 'service name', global_settings: {}}.to_json

      parser.parse data

      service.global_variables.should eq([])
    end

    it 'should parse global settings variables' do
      data = {name: 'service name', global_settings: global_settings}.to_json

      parser.parse data

      service.global_variables.size.should eq(2)

      var_1 = service.global_variables[0]
      var_1.name.should eq('foo')
      var_1.display_name.should eq('Foo Var')
      var_1.value.should be_nil

      var_2 = service.global_variables[1]
      var_2.name.should eq('bar')
      var_2.display_name.should eq('Bar Var')
      var_2.value.should be_nil
    end

    it 'should keep current values' do
      current_var = ExternalService::GlobalVariable.new({
        name: 'foo',
        display_name: 'Foo Var',
        value: 'foo value'
      })

      service.global_settings = {
        variables: [current_var]
      }

      data = {name: 'service name', global_settings: global_settings}.to_json

      parser.parse data

      service.global_variables.size.should eq(2)

      service.global_variables.detect{|x| x.name == 'foo'}.value.should eq('foo value')
    end
  end

  describe 'steps' do
    it 'should parse step' do
      data = {
        name: 'service name',
        steps: [
          name: 'step_1',
          display_name: 'Step 1',
          icon: 'medicalkit',
          callback_url: '/step_1',
          variables: [
            {name: 'input', display_name: 'Input Var'}
          ]
        ]
      }.to_json

      parser.parse data

      service.external_service_steps.size.should eq(1)
      step = service.external_service_steps.first
      step.name.should eq('step_1')
      step.display_name.should eq('Step 1')
      step.icon.should eq('medicalkit')
      step.callback_url.should eq('/step_1')
      step.variables.should eq([ExternalServiceStep::Variable.new('input', 'Input Var')])
      step.response_type.should eq('none')
      step.response_variables.should eq([])
      step.marked_for_destruction?.should be_false
    end

    it 'should parse step with response variables' do
      data = {
        name: 'service name',
        steps: [
          name: 'step_1',
          response: {
            type: 'variables',
            variables: [
              {name: 'response1', display_name: 'Response Var 1'},
              {name: 'response2', display_name: 'Response Var 2'}
            ]
          }
        ]
      }.to_json

      parser.parse data

      service.external_service_steps.size.should eq(1)
      step = service.external_service_steps.first
      step.name.should eq('step_1')
      step.response_type.should eq('variables')
      step.response_variables.should eq([
        ExternalServiceStep::Variable.new('response1', 'Response Var 1'),
        ExternalServiceStep::Variable.new('response2', 'Response Var 2')
      ])
      step.marked_for_destruction?.should be_false
    end

    it 'should update existing step and delete missing step' do
      service.name = 'service name'
      existing_step = service.external_service_steps.build
      existing_step.name = 'existing'
      missing_step = service.external_service_steps.build
      missing_step.name = 'missing'

      service.save!

      service.external_service_steps.count.should eq(2)

      data = {
        name: 'update service name',
        steps: [
          {
            name: 'new'
          },
          {
            name: 'existing',
            display_name: 'Updated existing name'
          }
        ]
      }.to_json

      parser.parse data

      service.name.should eq('update service name')
      service.external_service_steps.size.should eq(3)

      current_missing_step = service.external_service_steps.detect{|x| x.name == 'missing'}
      current_missing_step.marked_for_destruction?.should be_true

      current_new_step = service.external_service_steps.detect{|x| x.name == 'new'}
      current_new_step.marked_for_destruction?.should be_false
      current_new_step.new_record?.should be_true

      current_existing_step = service.external_service_steps.detect{|x| x.name == 'existing'}
      current_existing_step.marked_for_destruction?.should be_false
      current_existing_step.new_record?.should be_false
      current_existing_step.display_name.should eq('Updated existing name')
    end

  end

end
