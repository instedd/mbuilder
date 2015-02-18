class ExternalServiceParser
  def initialize(service)
    @service = service
  end

  def parse(data)
    json = JSON.parse(data)

    @service.name = json['name']

    parse_global_settings json['global_settings']

    parse_steps json['steps']

    @service
  end

private

  def parse_global_settings(json)
    if json.nil?
      @service.global_settings = {}
    else
      parse_global_variables json['variables']
    end
  end

  def parse_global_variables(json)
    if json.nil?
      @service.global_variables = []
    else
      current = @service.global_variables
      @service.global_variables = json.map do |json_var|
        new_var = parse_global_variable json_var
        current_var = current.detect{|x| x.name == new_var.name}
        new_var.value = current_var.value if current_var.present?
        new_var
      end
    end
  end

  def parse_steps(json)
    existing_steps_ids = @service.external_service_steps.pluck :id

    unless json.nil?
      json.each do |json_step|
        step = parse_step json_step
        existing_steps_ids.delete(step.id) unless step.new_record?
      end
    end

    @service.external_service_steps.each do |step|
      step.mark_for_destruction if !step.new_record? && existing_steps_ids.include?(step.id)
    end
  end

  def parse_step(json)
    step = @service.external_service_steps.find_or_initialize_by_name json['name']

    step.display_name = json['display_name'] if json['display_name']
    step.icon = json['icon'] if json['icon']
    step.callback_url = json['callback_url'] if json['callback_url']

    step.variables = parse_variables json['variables']

    response = json['response'] || {}

    step.response_type = ['variables','none'].include?(response['type']) ? response['type'] : 'none'

    case step.response_type
    when 'variables'
      step.response_variables = parse_variables response['variables']
    when 'none'
      step.response_variables = []
    end

    # FIXME: Should not save when parsing!! See how to mark for update
    step.save if !step.new_record?
    step
  end

  def parse_global_variable json
    ExternalService::GlobalVariable.new.tap do |var|
      var.name = json['name']
      var.display_name = json['display_name']
    end
  end

  def parse_variables json
    json ||= []
    json.map do |json_var|
      parse_variable json_var
    end
  end

  def parse_variable json
    ExternalServiceStep::Variable.new.tap do |var|
      var.name = json['name']
      var.display_name = json['display_name']
    end
  end
end
