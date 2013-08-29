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
        'guid' => name.downcase,
        'fields' => fields.map { |field| {'name' => name, 'guid' => name.downcase} },
      }
    )
  end

  class TriggerHelper
    def initialize(application)
      @application = application
      @actions = []
    end

    def message(text)
      pieces = []
      parse_message(text) do |kind, text|
        if text == 'text'
          pieces.push 'kind' => 'text', 'text' => text
        else
          pieces.push 'kind' => 'pill', 'text' => text, 'guid' => text.downcase
        end
      end
      @message = Message.from_hash({'pieces' => pieces})
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
        @actions << Action.from_hash({'kind' => kind, 'table' => table, 'field' => field, 'pill' => pill})
      else
        raise "Wrong action text: #{text}"
      end
    end

    def send_message(recipient, text)
      case recipient
      when /text (.+)/
        recipient = {'kind' => 'text', 'guid' => $1}
      else
        raise "Uknonw recipient: #{recipient}"
      end

      bindings = []
      parse_message(text) do |kind, msg_text|
        if kind == 'text'
          bindings.push 'kind' => 'text', 'guid' => msg_text
        else
          bindings.push message_binding(msg_text)
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

  def actions(text)
    actions = text.split(',').map(&:strip)
    actions.map { |action_text| action(action_text) }
  end

  def action(text)
    case text
    when /(create entity|select entity|store entity value) (\w+)\.(\w+) = (.+)/
      kind = $1
      table = $2
      field = $3
      pill = pill($4)
      hash = {'kind' => kind.gsub(' ', '_'), 'table' => table, 'field' => field, 'pill' => pill}
    else
      raise "Unknown action: #{text}"
    end

    Action.from_hash(hash)
  end

  def pill(text)
    if text =~ /implicit (.+)/
      {'kind' => 'implicit', 'guid' => $1.strip}
    else
      {'kind' => 'piece', 'guid' => text.strip}
    end
  end

  def message_binding(text)
    if text =~ /implicit (.+)/
      {'kind' => 'implicit', 'guid' => $1.strip}
    else
      {'kind' => 'message_piece', 'guid' => text.strip}
    end
  end

  def accept_message(from, body)
    application.accept_message(from: from, body: body)
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

    results.each_with_index do |result, i|
      result = result["_source"]
      result["type"].should eq(table)
      result["properties"].should eq(data[i])
    end
  end

  def parse_message(text)
    pieces = []
    pos = 0
    idx = text.index("{", pos)
    while idx
      yield 'text', text[pos ... idx].strip
      other_idx = text.index("}", idx + 1)
      name = text[idx + 1 ... other_idx].strip
      yield 'pill', name
      pos = other_idx + 1
      idx = text.index("{", pos)
    end
    rest = text[pos .. -1].strip
    if rest.length > 0
      yield 'text', rest
    end
  end
end
