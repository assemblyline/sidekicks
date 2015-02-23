require 'spec_helper'
require 'sidekicks/elb'
require 'support/aws_test_factories'

describe Sidekicks::ELB do
  let(:credentials) { AWSCredentials.new }
  let(:server) { ComputeFactory.new(credentials).setup_instance(self) }
  let(:elb) { ELBFactory.new(credentials).setup_elb('foo-bar-testing') }

  before do
    Fog.mock!
    Fog::Mock.reset
    server
    elb
  end

  describe '#startup' do
    it 'registers the instance with the elb' do
      subject.startup
      expect(elb.reload.instances).to include server.id
    end
  end

  describe '#shutdown' do
    before do
      subject.startup
    end

    it 'registers the instance with the elb' do
      subject.shutdown
      expect(elb.reload.instances).to_not include server.id
    end
  end
end
