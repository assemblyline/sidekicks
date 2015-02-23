require 'docker'
require 'etcd'

module Sidekicks
  class Vulcand
    def initialize
      self.hostname = ENV.fetch('HOSTNAME')
      self.docker_host = ENV.fetch('DOCKER_HOST')
      self.container_name = ENV.fetch('CONTAINER_NAME')
      self.container_port = ENV.fetch('CONTAINER_PORT')
      self.backend = ENV.fetch('VULCAND_BACKEND')
    end

    def interval
      2
    end

    def work
      etcd.set("/vulcand/backends/#{backend}/servers/#{container_name}", value: server_config, ttl: 5)
    end

    def shutdown
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
      @_container ||= Docker::Container.get(container_name, docker_connection)
    end

    def docker_connection
      @_docker_connection ||= Docker::Connection.new(docker_host, {})
    end

    def etcd
      @_etcd ||= Etcd.client
    end
  end
end
