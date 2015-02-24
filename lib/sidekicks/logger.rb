module Sidekicks
  module Logger
    extend self

    def log(message)
      STDOUT.puts message
      STDOUT.flush
    end
  end
end
