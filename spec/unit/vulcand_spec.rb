require 'spec_helper'
require 'support/vcr'
require 'sidekicks/vulcand'

describe Sidekicks::Vulcand do
  let(:mock_etcd) { double }

  before do
    allow(Etcd).to receive(:client).and_return(mock_etcd)
    ENV['HOSTNAME']        = '10.234.17.44'
    ENV['DOCKER_HOST']     = 'https://192.168.59.103:2376'
    ENV['CONTAINER_NAME']  = 'foo'
    ENV['CONTAINER_PORT']  = '3000'
    ENV['VULCAND_BACKEND'] = 'awesome'
  end

  describe '#interval' do
    it 'works every 2 seconds' do
      expect(subject.interval).to eq 2
    end
  end

  describe '#work', :vcr do
    it 'upserts the server with a ttl of 5' do
      expect(mock_etcd).to receive(:set).with(
        '/vulcand/backends/awesome/servers/foo',
        value: '{"URL": "http://10.234.17.44:49155"}',
        ttl: 5,
      )
      subject.work
    end
  end

  describe '#shutdown' do
    it 'removes the server' do
      expect(mock_etcd).to receive(:delete).with('/vulcand/backends/awesome/servers/foo')
      subject.shutdown
    end
  end
end
