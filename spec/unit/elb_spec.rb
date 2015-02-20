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

  describe '#register' do
    it 'registers the instance with the elb' do
      subject.register
      expect(elb.reload.instances).to include server.id
    end
  end

  describe '#deregister' do
    before do
      subject.register
    end

    it 'registers the instance with the elb' do
      subject.deregister
      expect(elb.reload.instances).to_not include server.id
    end
  end
end
