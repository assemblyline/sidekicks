require 'spec_helper'
require 'sidekicks/cli'

describe Sidekicks::Cli do
  describe '.run' do
    context 'with an unsupported command' do
      it 'fails' do
        expect do
          described_class.run('foobah')
        end.to raise_error 'foobah is not a supported command'
      end
    end

    context 'with a supported command' do
      it 'runs the correct class' do
        expect(Sidekicks::Runner).to receive(:run) do |sidekick|
          expect(sidekick).to eq Sidekicks::ELB
        end
        Sidekicks::Cli.run('elb')
      end
    end
  end
end
