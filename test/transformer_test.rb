require 'minitest/autorun'
require 'sequel'

class TransformerTest < Minitest::Test
  def setup
    @db = Sequel.sqlite
    @db.extension :transformer
    ActiveSupport::Notifications.notifier = ActiveSupport::Notifications.notifier.class.new
  end

  def test_transformer_yields_chain
    yielded = nil
    @db.transformer { |arg| yielded = arg }
    assert_instance_of Sequel::Transformer::Chain, yielded
  end

  def test_step_yields_db
    yielded = nil
    @db.transformer do |chain|
      chain.step do |arg|
        yielded = arg
      end
    end
    assert_equal @db, yielded
  end

  def test_build_chain
    chain = @db.transformer "Update widget metadata"

    chain.step "ensure destination tables" do |db|
      db.create_table?(:widgets) do
        primary_key :id
        column :name, :string
      end
    end
    chain.step "insert test records" do |db|
      db.run %[
        INSERT INTO widgets (name) values ('toothbrush');
        INSERT INTO widgets (name) values ('toaster oven');
      ]
    end
    chain.step "add age columns unless exists" do |db|
      db.alter_table(:widgets) do
        add_column(:age, :integer, default: -1) unless db[:widgets].columns.include?(:age)
      end
    end

    chain.run

    assert_equal @db[:widgets].order(:id).all, [
      { id: 1, name: 'toothbrush', age: -1 },
      { id: 2, name: 'toaster oven', age: -1 }
    ]
  end

  def test_runs_steps
    @db.transformer "Update widget metadata" do |chain|
      chain.step "ensure destination tables" do |db|
        db.create_table?(:widgets) do
          primary_key :id
          column :name, :string
        end
      end
      chain.step "insert test records" do |db|
        db.run %[
          INSERT INTO widgets (name) values ('computer');
          INSERT INTO widgets (name) values ('desk chair');
        ]
      end
      chain.step "add age columns unless exists" do |db|
        db.alter_table(:widgets) do
          add_column(:age, :integer, default: 0) unless db[:widgets].columns.include?(:age)
        end
      end
    end

    assert_equal @db[:widgets].order(:id).all, [
      { id: 1, name: 'computer', age: 0 },
      { id: 2, name: 'desk chair', age: 0 }
    ]
  end

  def test_instruments_process
    events = []

    ActiveSupport::Notifications.subscribe(/^sequel-transformer/) do |*args|
      events << ActiveSupport::Notifications::Event.new(*args)
    end

    @db.transformer 'beginner' do |chain|
      chain.step('hello'){}
      chain.step('world'){}
    end

    assert_equal events.map(&:name), [
      'sequel-transformer.step',
      'sequel-transformer.step',
      'sequel-transformer.chain'
    ]

    assert_equal events.map(&:payload).map{|p|[p[:title],p[:description]]}, [
      ['beginner', 'hello'],
      ['beginner', 'world'],
      ['beginner', nil]
    ]
  end

  def test_errors_halt_execution
    step_called = false

    begin
      @db.transformer do |chain|
        chain.step{ raise }
        chain.step{ step_called = true }
      end

      fail
    rescue
    end

    refute step_called, "errors must prevent remaining steps from running"
  end
end
