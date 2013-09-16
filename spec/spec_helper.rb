# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require File.expand_path("../../spec/blueprints", __FILE__)
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
        'fields' => fields.map { |field| {'name' => field, 'guid' => "#{field.underscore}"} },
      }
    )
  end

  class TriggerHelper
    def initialize(application)
      @application = application
      @actions = []
    end

    def message(text, options = {})
      pieces = []
      parse_message(text) do |kind, text|
        if kind == 'text'
          pieces.push 'kind' => 'text', 'text' => text
        else
          pieces.push 'kind' => 'placeholder', 'text' => text, 'guid' => "placeholder_#{text.downcase}"
        end
      end
      @message = Message.from_hash({'pieces' => pieces})
      @message.from = options[:from]
    end

    def create_entity(text)
      new_entity_action 'create_entity', text
    end

    def select_entity(text)
      new_entity_action 'select_entity', text
    end

    def store_entity_value(text)
      new_entity_action 'store_entity_value', text
    end

    def new_entity_action(kind, text)
      if text =~ /(\w+)\.(\w+) = (.+)/
        table = $1
        field = $2
        pill = pill($3)
        @actions << Action.from_hash({'kind' => kind, 'table' => "#{table}", 'field' => "#{field}", 'pill' => pill})
      else
        raise "Wrong action text: #{text}"
      end
    end

    def send_message(recipient, text)
      case recipient
      when /'(.+)'/
        recipient = {'kind' => 'text', 'guid' => $1}
      when /\*(.+)/
        recipient = {'kind' => 'field_value', 'guid' => $1}
      else
        raise "Unknown recipient: #{recipient}"
      end

      bindings = []
      parse_message(text) do |kind, msg_text|
        if kind == 'text'
          bindings.push 'kind' => 'text', 'guid' => msg_text
        else
          bindings.push pill(msg_text)
        end
      end

      @actions << Actions::SendMessageAction.from_hash('message' => bindings, 'recipient' => recipient)
    end

    def trigger
      trigger = @application.triggers.make_unsaved
      trigger.logic = Logic.new @message, @actions
      trigger.save!

      trigger
    end
  end

  def new_trigger(&block)#(message, *actions)
    helper = TriggerHelper.new(application)
    helper.instance_eval(&block)
    helper.trigger
  end

  def pill(text)
    case text
    when /\*(.+)/
      {'kind' => 'field_value', 'guid' => "#{$1}"}
    when /'(.+)'/
      {'kind' => 'literal', 'guid' => "literal_#{$1}", 'text' => $1}
    when "{phone_number}"
      {'kind' => 'placeholder', 'guid' => "phone_number"}
    when /\{(.+)\}/
      {'kind' => 'placeholder', 'guid' => "placeholder_#{$1}"}
    else
      puts text
      raise 'wtf?'
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

    data.each do |properties|
      application.tire_index.store type: table, properties: properties
    end
    application.tire_index.refresh
  end

  def assert_data(table, *data)
    data = data[0] if data.length == 1 && data[0].is_a?(Array)

    index = application.tire_index
    index.exists?.should be_true

    results = application.tire_search(table).perform.results
    results.length.should eq(data.length)

    results = results.map { |result| result["_source"]["properties"] }

    assert_sets_equal results, data
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
end
