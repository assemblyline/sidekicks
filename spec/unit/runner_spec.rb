require 'spec_helper'
require 'sidekicks/runner'
require 'English'

describe Sidekicks::Runner do

  let(:testkick) { Sidekicks::Testkick }

  context 'running the startup method' do
    it 'runs the startup method' do
      output = run_for(0.1, testkick)
      expect(output).to include "I am starting up\n"
    end
  end

  context 'running the work method' do
    it 'runs the work method every interval' do
      output = run_for(0.5, testkick)
      expect(output.count("I am working\n")).to eq 5
    end
  end

  context 'running the shutdown method' do
    it 'runs the shutdown method when killed with TERM' do
      output = run_for(0.1, testkick)
      expect(output).to include "I have shutdown\n"
    end

    it 'exits cleanly' do
      run_for(0.1, testkick)
      Process.wait
      expect($CHILD_STATUS).to be_success
    end
  end

  context 'the whole flow' do
    it 'runs the methods in the expected order' do
      output = run_for(0.1, testkick)
      expect(output.first).to eq "I am starting up\n"
      expect(output[1]).to eq "I am working\n"
      expect(output.last).to eq "I have shutdown\n"
    end
  end

  context 'when the sidekick does not have a work method' do
    let(:testkick) { Sidekicks::NoWorkKick }

    it 'runs the methods in the expected order' do
      output = run_for(0.1, testkick)
      expect(output).to eq ["I am starting up\n", "I have shutdown\n"]
    end
  end

  context 'when the sidekick does not define interval' do
    let(:testkick) { Sidekicks::NoIntervalKick }

    it 'works at 1 second intervals' do
      output = run_for(0.9, testkick)
      expect(output.count("I am working\n")).to eq 1
    end
  end

  def run_for(time, testkick)
    rout, wout = IO.pipe

    runner = fork do
      STDOUT.reopen(wout)
      Sidekicks::Runner.run(testkick)
    end
    sleep time

    Process.kill('TERM', runner)

    wout.close
    rout.readlines
  end

end

module Sidekicks
  class Testkick
    def interval
      0.1
    end

    def startup
      log 'I am starting up'
    end

    def work
      log 'I am working'
    end

    def shutdown
      log 'I have shutdown'
    end

    def log(msg)
      puts msg
      STDOUT.flush
    end
  end

  class NoWorkKick
    def interval
      0.1
    end

    def startup
      log 'I am starting up'
    end

    def shutdown
      log 'I have shutdown'
    end

    def log(msg)
      puts msg
      STDOUT.flush
    end
  end

  class NoIntervalKick
    def startup
      log 'I am starting up'
    end

    def work
      log 'I am working'
    end

    def shutdown
      log 'I have shutdown'
    end

    def log(msg)
      puts msg
      STDOUT.flush
    end
  end
end
