require 'fog'
require 'open-uri'
require 'sidekicks/logger'

module Sidekicks
  class ELB

    def initialize
      self.name   = ENV['AWS_ELB_NAME']
      self.tag    = ENV['AWS_ELB_TAG']
      self.region = ENV.fetch 'AWS_REGION'
      self.key    = ENV.fetch 'AWS_ACCESS_KEY'
      self.secret = ENV.fetch 'AWS_SECRET_KEY'
    end

    def interval
      60
    end

    def work
      register_if_required
    end

    def shutdown
      deregister_if_required
    end

    protected

    attr_accessor :name, :region, :key, :secret, :tag

    private

    def register_if_required
      elbs.each do |elb|
        next if elb.instances.include? instance
        Logger.log "registering instance #{instance} with elb #{elb.id}"
        elb.register_instances [instance]
      end
    end

    def deregister_if_required
      elbs.each do |elb|
        next unless elb.instances.include? instance
        Logger.log "deregistering instance #{instance} with elb #{elb.id}"
        elb.deregister_instances [instance]
      end
    end

    def elbs
      if tag
        all_elbs.select { |elb| elb.tags[tag] }
      elsif name
        [all_elbs.get(name)]
      end
    end

    def all_elbs
      Fog::AWS::ELB.new(
        aws_access_key_id: key,
        aws_secret_access_key: secret,
        region: region,
      ).load_balancers
    end

    def instance
      @_instance ||= OpenURI.open_uri('http://169.254.169.254/latest/meta-data/instance-id').read
    end
  end
end
