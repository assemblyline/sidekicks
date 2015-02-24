require 'docker'
require 'etcd'
require 'sidekicks/logger'

module Sidekicks
  class Vulcand
    def initialize
      self.hostname = ENV.fetch('HOSTNAME')
      self.container_name = ENV.fetch('CONTAINER_NAME')
      self.container_port = ENV.fetch('CONTAINER_PORT')
      self.backend = ENV.fetch('VULCAND_BACKEND')
      Docker.url = 'tcp://172.17.42.1:2375'
    end

    def interval
      2
    end

    def work
      conf = server_config
      Logger.log "upserting #{container_name} in the backend: #{backend} with config: #{conf}"
      etcd.set("/vulcand/backends/#{backend}/servers/#{container_name}", value: conf, ttl: 5)
    end

    def shutdown
      Logger.log "removing #{container_name} from the backend: #{backend}"
      etcd.delete("/vulcand/backends/#{backend}/servers/#{container_name}")
    end

    protected

    attr_accessor :docker_host, :container_name, :container_port, :backend, :hostname

    private

    def server_config
      '{"URL": "' + container_url + '"}'
    end

    def container_url
      "http://#{hostname}:#{exposed_port}"
    end

    def exposed_port
      container.json['NetworkSettings']['Ports']["#{container_port}/tcp"].first['HostPort']
    end

    def container
      @_container ||= Docker::Container.get(container_name)
    end

    def etcd
      @_etcd ||= Etcd.client(host: '172.17.42.1')
    end
  end
end
