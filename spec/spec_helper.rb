# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require File.expand_path("../../spec/blueprints", __FILE__)
require File.expand_path("../../spec/trigger_helper", __FILE__)
require 'rspec/rails'
require 'rspec/autorun'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

RSpec.configure do |config|
  # ## Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  # config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = "random"

  config.after(:all) { Tire.index('*test*').delete }

  config.include Devise::TestHelpers, :type => :controller

  def new_application(tables)
    tables = tables.split(";").map(&:strip)
    tables = tables.map do |table|
      name, fields = table.split(':').map(&:strip)
      fields = fields.split(',').map(&:strip)
      table(name, fields)
    end

    app = Application.make_unsaved
    app.tables = tables
    app.save!

    app
  end

  def table(name, fields)
    Table.from_hash(
      {
        'name' => name,
        'guid' => "#{name.downcase}",
        'kind' => 'local',
        'fields' => fields.map { |field| {'name' => field, 'guid' => "#{field.underscore}"} },
      }
    )
  end

  def new_trigger(&block)#(message, *actions)
    instance_eval_trigger_helper(&block).trigger
  end

  def new_periodic_task(&block)#(message, *actions)
    instance_eval_trigger_helper(&block).periodic_task
  end

  def new_validation_trigger(field_guid, &block)
    instance_eval_trigger_helper(&block).validation_trigger(field_guid)
  end

  def new_external_trigger(&block)
    instance_eval_trigger_helper(&block).external_trigger
  end

  def instance_eval_trigger_helper(&block)
    helper = TriggerHelper.new(application)
    helper.instance_eval(&block)
    helper
  end

  def pill(text)
    case text
    when /\?(\w+)/
      {'kind' => 'parameter', 'guid' => "placeholder_#{$1}"}
    when /\*(\w+)\((.+)\)/
      {'kind' => 'field_value', 'guid' => $2, 'aggregate' => $1}
    when /\*(.+)/
      {'kind' => 'field_value', 'guid' => $1}
    when /'(.+)'/
      {'kind' => 'literal', 'guid' => "literal_#{$1}", 'text' => $1}
    when /\{(phone_number|invalid_value|received_at)\}/
      {'kind' => 'placeholder', 'guid' => $1}
    when /\{(.+)\}/
      {'kind' => 'placeholder', 'guid' => "placeholder_#{$1}"}
    else
      raise "Unknown pill helper: #{text}"
    end
  end

  def parse_condition(text)
    left, op, right = text.split(' ', 3)
    if left && op && right
      left = Pill.from_hash(pill(left))
      right = Pill.from_hash(pill(right))
      [left, op, [right]]
    else
      raise "Expected three pieces separated by spaces for condition: #{text}"
    end
  end

  def accept_message(from, body)
    application.accept_message('from' => from, 'body' => body)
  end

  def add_table(table)
    name, fields = table.split(':').map(&:strip)
    fields = fields.split(',').map(&:strip)
    application.tables << table(name, fields)
  end

  def add_data(table, *data)
    data = data[0] if data.length == 1 && data[0].is_a?(Array)

    data.to_f_if_looks_like_number.each do |properties|
      now = Tire.format_date(Time.now)
      application.tire_index.store type: table, properties: properties, created_at: now, updated_at: now
    end
    application.tire_index.refresh
  end

  def assert_data(table, *data)
    data = data[0] if data.length == 1 && data[0].is_a?(Array)

    index = application.tire_index(false)
    if index.exists?
      results = application.tire_search(table).perform.results
      results.length.should eq(data.length)

      results = results.map { |result| result["_source"]["properties"] }

      assert_sets_equal results, data
    else
      data.length.should eq(0)
    end
  end

  def assert_sets_equal(actual_results, expected_results)
    actual_results.length.should eq(expected_results.length)
    actual_results.each do |result|
      actual_results_count = actual_results.count(result)
      expected_results_count = expected_results.count(result)
      if actual_results_count != expected_results_count
        fail("'#{result}' found #{expected_results_count} times in expected results, but was found #{actual_results_count} in actual results")
      end
    end
  end

  def parse_message(text)
    case text
    when /(.*?)\{(.+)\}(.*?)\{(.+)\}(.*?)\{(.+)\}(.*?)\{(.+)\}(.*)/
      v1, v2, v3, v4, v5, v6, v7, v8, v9= $1, $2, $3, $4, $5, $6, $7, $8, $9
      yield 'text', v1.strip
      yield 'pill', v2
      yield 'text', v3.strip if v3.present?
      yield 'pill', v4
      yield 'text', v5.strip if v5.present?
      yield 'pill', v6
      yield 'text', v7.strip if v7.present?
      yield 'pill', v8
      yield 'text', v9.strip if v9.present?
    when /(.*?)\{(.+)\}(.*?)\{(.+)\}(.*)/
      v1, v2, v3, v4, v5= $1, $2, $3, $4, $5
      yield 'text', v1.strip
      yield 'pill', v2
      yield 'text', v3.strip if v3.present?
      yield 'pill', v4
      yield 'text', v5.strip if v5.present?
    when /(.*?)\{(.+)\}(.*)/
      v1, v2, v3 = $1, $2, $3
      yield 'text', v1.strip
      yield 'pill', v2
      yield 'text', v3.strip if v3.present?
    else
      yield 'text', text.try(:strip)
    end
  end

  RSpec::Matchers.define :be_near_of do |expected|
    match do |actual|
      actual.utc.to_date == expected.utc.to_date && actual.utc.seconds_since_midnight.to_i == expected.utc.seconds_since_midnight.to_i
    end
  end
end
