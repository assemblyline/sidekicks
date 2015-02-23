#Assemblyine
## Sidekicks

Generic sidekicks to aid in registration and health checking of containers running in production / pre-production.

## Vulcand

The vulcand sideick is designed to register a container with
the vulcand reverse proxy.

It finds the port exposed in the given docker container and sets up a server in the given backend.

### Usage

`docker run [-e ...] assemblyline/sidekicks vulcand`

### Config

The ELB sidekick takes its configuration from the environment.

The id of the current instance is looked up dynamically using [ec2 instance metadata](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-instance-metadata.html)

|ENV Var           | Description                                              |
|------------------|----------------------------------------------------------|
|`HOSTNAME`        | The hostname or ip of the current instance               |
|`CONTAINER_NAME`  | The name of the container to upsert                      |
|`CONTAINER_PORT`  | The container port to lookup exposed port by             |
|`VULCAND_BACKEND` | The name of the Vulcand backend to upsert this server in |


## ELB

The ELB sidekick is designed to register an instance with an Amazon Web Services
Elastic Load Balancer.

It registers the current instance with the named ELB on start, if the sidekick
receives an INT or TERM signal it will deregister the instance.


### Usage

`docker run [-e ...] assemblyline/sidekicks elb`

### Config

The ELB sidekick takes its configuration from the environment.

The id of the current instance is looked up dynamically using [ec2 instance metadata](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-instance-metadata.html)

|ENV Var          | Description                          |
|-----------------|--------------------------------------|
|`AWS_ELB_NAME`   | The name of the ELB to register with |
|`AWS_REGION`     | The name of the AWS Region           |
|`AWS_ACCESS_KEY` | The AWS Access Key to use            |
|`AWS_SECRET_KEY` | The AWS Secret Key to use            |

### Limitations

* It only works with AWS Elastic Load Balancers
* It needs the load balancer to be set up properly
* Remember an ELB can only balance instances in the same region
