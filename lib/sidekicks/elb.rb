require 'fog'
require 'open-uri'
require 'sidekicks/logger'

module Sidekicks
  class ELB

    def initialize
      self.name   = ENV.fetch 'AWS_ELB_NAME'
      self.region = ENV.fetch 'AWS_REGION'
      self.key    = ENV.fetch 'AWS_ACCESS_KEY'
      self.secret = ENV.fetch 'AWS_SECRET_KEY'
    end

    def startup
      Logger.log "registering instance #{instance} with elb #{elb.id}"
      elb.register_instances [instance]
    end

    def shutdown
      Logger.log "deregistering instance #{instance} with elb #{elb.id}"
      elb.deregister_instances [instance]
    end

    protected

    attr_accessor :name, :region, :key, :secret

    private

    def elb
      @elb ||= Fog::AWS::ELB.new(
        aws_access_key_id: key,
        aws_secret_access_key: secret,
        region: region,
      ).load_balancers.get(name)
    end

    def instance
      @_instance ||= OpenURI.open_uri('http://169.254.169.254/latest/meta-data/instance-id').read
    end
  end
end
