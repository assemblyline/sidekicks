require 'sidekicks/runner'

module Sidekicks
  class Cli
    def self.run(command)
      new(command).run
    end

    def initialize(command)
      self.command = command
    end

    def run
      Runner.run(sidekick_for(command))
    end

    protected

    attr_accessor :command

    def supported?
      supported_commands.keys.include? command
    end

    def supported_commands
      {
        'elb' => ->() { ELB },
        'vulcand' => ->() { Vulcand },
      }
    end

    def sidekick_for(command)
      fail "#{command} is not a supported command" unless supported?
      require "sidekicks/#{command}"
      supported_commands[command].call
    end
  end
end
