require 'spec_helper'
require 'sidekicks/elb'
require 'support/aws_test_factories'

describe Sidekicks::ELB do
  let(:credentials) { AWSCredentials.new }
  let(:server) { ComputeFactory.new(credentials).setup_instance(self) }

  context 'one named elb' do
    let(:elb) { ELBFactory.new(credentials).setup_elb('foo-bar-testing') }

    before do
      Fog.mock!
      Fog::Mock.reset
      server
      elb
    end

    describe '#interval' do
      it 'is 1 minute' do
        expect(subject.interval).to eq 60
      end
    end

    describe '#work' do
      it 'registers the instance with the elb' do
        subject.work
        expect(elb.reload.instances).to include server.id
      end
    end

    describe '#shutdown' do
      before do
        subject.work
      end

      it 'deregisters the instance with the elb' do
        subject.shutdown
        expect(elb.reload.instances).to_not include server.id
      end
    end
  end

  context 'two tagged elbs' do
    let(:elb_factory) { ELBFactory.new(credentials) }

    def tagged_elbs
      elb_factory.get_elbs_with_tag('nova')
    end

    def untagged_elbs
      elb_factory.get_elbs_with_tag('idontcare')
    end

    before do
      Fog.mock!
      Fog::Mock.reset
      server
      elb_factory.tagged_elbs('nova', 2)
      elb_factory.tagged_elbs('idontcare', 3)

    end

    describe '#work' do
      it 'registers the instance with the tagged elbs' do
        with_env('AWS_ELB_NAME' => nil, 'AWS_ELB_TAG' => 'nova') do
          subject.work
          tagged_elbs.each do |elb|
            expect(elb.instances).to include server.id
          end
        end
      end

      it 'dones not the registers the instance with the untagged elbs' do
        with_env('AWS_ELB_NAME' => nil, 'AWS_ELB_TAG' => 'nova') do
          subject.work
          untagged_elbs.each do |elb|
            expect(elb.instances).to_not include server.id
          end
        end
      end
    end

    describe '#shutdown' do
      it 'deregisters the instance from all the tagged elbs' do
        with_env('AWS_ELB_NAME' => nil, 'AWS_ELB_TAG' => 'nova') do
          subject.work
          subject.shutdown
          tagged_elbs.each do |elb|
            expect(elb.instances).to_not include server.id
          end
        end
      end
    end
  end
end
