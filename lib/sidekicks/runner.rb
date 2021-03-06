module Sidekicks
  class Runner
    def self.run(sidekick)
      new(sidekick).run
    end

    def initialize(sidekick)
      self.sidekick = sidekick.new
    end

    def run
      at_exit do
        sidekick.shutdown
        exit 0
      end

      startup

      loop do
        work
        sleep interval || 1
      end
    end

    protected

    attr_accessor :sidekick

    private

    def interval
      sidekick.interval if defined?(sidekick.interval)
    end

    def startup
      sidekick.startup if defined?(sidekick.startup)
    end

    def work
      sidekick.work if defined?(sidekick.work)
    end
  end
end
