require 'active_support/notifications'
require 'securerandom'
require 'sequel/transformer/version'

module Sequel
  module Transformer
    def transformer(title = SecureRandom.uuid)
      chain = Chain.new(title, self)
      if block_given?
        yield chain
        chain.run
      end
      chain
    end

    class Chain
      def initialize(title, db)
        @title = title
        @db = db
        @steps = []
      end

      def step(description = nil, &block)
        raise ArgumentError, 'must pass a block' unless block_given?
        description ||= "step-#{@steps.count}"
        @steps << [description, block]
      end

      def run
        instrument('chain') {
          @steps.each_with_index do |(description, block), index|
            instrument('step', index: index, description: description) {
              block.call(@db)
            }
          end
        }
      end

      def instrument(name, extras = {}, &block)
        ActiveSupport::Notifications.instrument("sequel-transformer.#{name}", { title: @title }.merge(extras), &block)
      end
    end
  end

  Database.register_extension(:transformer, Transformer)
end
