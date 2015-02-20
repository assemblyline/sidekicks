class AWSCredentials
  def initialize(key: 'AWSKEY', secret:'AWSSEKRET', region:'eu-west-1')
    @key, @secret, @region = key, secret, region
    set_env
  end

  attr_reader :key, :secret, :region

  protected

  def set_env
    ENV['AWS_ACCESS_KEY'] = key
    ENV['AWS_SECRET_KEY'] = secret
    ENV['AWS_REGION']     = region
  end
end

class ComputeFactory
  def initialize(credentials)
    self.credentials = credentials
  end

  def setup_instance(test_context)
    server = connection.servers.create
    mock_instance_id_metadata(server.id, test_context)
    server
  end

  def connection
    Fog::Compute.new(
      provider: 'AWS',
      aws_access_key_id: credentials.key,
      aws_secret_access_key: credentials.secret,
      region: credentials.region,
    )
  end

  protected

  attr_accessor :credentials

  private

  def mock_instance_id_metadata(instance_id, test_context)
    open_uri_double = test_context.double(:open_uri, read: instance_id)
    test_context.allow(OpenURI).to test_context.receive(:open_uri).with('http://169.254.169.254/latest/meta-data/instance-id').and_return(open_uri_double)
  end

end

class ELBFactory
  def initialize(credentials)
    self.credentials = credentials
  end

  def setup_elb(name)
    setup_env_vars(name)
    availability_zones = %w(eu-west-1a eu-west-1b eu-west-1c)
    listeners = [{ 'Protocol' => 'HTTP', 'LoadBalancerPort' => 80, 'InstancePort' => 80, 'InstanceProtocol' => 'HTTP' }]
    connection.create_load_balancer(availability_zones, name, listeners)
    connection.load_balancers.get(name)
  end

  protected

  attr_accessor :credentials

  private

  def setup_env_vars(elb_name)
    ENV['AWS_ELB_NAME']   = elb_name
  end

  def connection
    Fog::AWS::ELB.new(
      aws_access_key_id: credentials.key,
      aws_secret_access_key: credentials.secret,
      region: credentials.region,
    )
  end
end
