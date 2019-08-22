**Basic information.**

This is a code for deploying web-applications using VPC/EC2/ALB/CloudWatch in AWS.
Example of docker application is taken from here: https://github.com/autopilotpattern/hello-world.

**The automation includes:**

1. Terraform modules for VPC, Traget Group, Application Load Balancer, Autoscaling group, CloudWatch alarms
2. Python3 small self-written framework for dealing with creation/deletion AWS resources, managing terraform modules and variables
3. Configuration files for AWS resources and application
4. Dockerfile to run framework locally or on CI system

**Details**

**AWS resources and security:**

I suggest that to be security compliant application should be running in AWS VPC private subnets. Application can be only
accessible for external customers through external Application Load Balancer DNS name via 80 port.
You can use existing VPC in your account or could create one within framework.
On top of VPC we place application stack based on Target Group, Application Load Balancer and Autoscaling Group.

**Prerequisites (are NOT covered by framework, you need to create them first):**

1. Valid AWS account
2. Valid AWS configuration file under ~/.aws OR valid AWS Environment variables OR valid AWS assumed role with
VPC/EC2/S3/CloudWatch write permissions
3. Existing S3 bucket for terraform state files opened for write permissions from step 2
4. Existing EC2 Instance Profile with EC2 and CloudWatch Admin permissions
5. Existing AWS Key for EC2

**Application managing:**

For task I'm using EC2 instance USERDATA with bash script for installing/running small "Hello World" application.
```sh
#!/bin/bash

yum update -y
yum -y install git docker
service docker restart
curl -L "https://github.com/docker/compose/releases/download/1.24.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
git clone https://github.com/autopilotpattern/hello-world.git
cd hello-world
docker-compose up -d
```

**Scaling and monitoring:**

The installation includes in-built basic CloudWatch monitoring for EC2/ALB/ASG/TG.
Also scaling IN/OUT is included. For that reason terraform module includes creation of "Scaling Policies" based on some alarm event created by "cwalarms" module.
For test application I suggest to use 'CPUUtilization' metric for that alarm. If threshold for 'CPUUtilization' is more than certain value then ScalingOUT action
scales out application and vise versa.

**Configuration files:**

Basically configuration files keep terraform variable in json format. Before running resources creation you need to fill out files with
correct values. Files are located under the configuration folder.

Example of VPC configuration:
```sh
{
  "default": {
    "default": {
      "state_bucket": "check-code-test", //existing s3 bucket for keeping state files
      "state_bucket_region": "eu-west-1" // bucket region for keeping state files
    },
      "eu-west-1": { // region where to create VPC
        "availability_zones": "eu-west-1a,eu-west-1b", // which availability zones to use
        "private_subnet_cidrs": "10.0.128.0/18,10.0.192.0/18", // ranges for private networks
        "public_subnet_cidrs": "10.0.0.0/18,10.0.64.0/18", // ranges for public networks
        "elb_access_ranges": "0.0.0.0/0", // who can reach ALB/ELB (by default all customers)
        "vpc_cidr": "10.0.0.0/16", // IP network for VPC
        "elb_access_ports": "80", // protocol for customers
        "elb_backend-port-rule1": "80" // protocol for backend
      }
    }
}
```

Example of application stack configuration:

```sh
{
  "default": {
    "default": {
      "asg_instance_profile": "arn:aws:iam::XXXXXXXXXXXX:instance-profile/check-code-test", // existing instance profile to attach to ec2
      "state_bucket": "check-code-test", //existing s3 bucket for keeping state files
      "state_bucket_region": "eu-west-1", // bucket region for keeping state files
      "service_name": "application" //application name
    },
    "eu-west-1": {
      "vpc_id": "vpc-0e8141f50ac5b2c82", // VPC ID (existing or can be taken from VPC creation step)
      "tg_name": "application", // Target group name
      "alb_name": "application-alb", // ALB name
      "tg_health_check_path": "/index.html", //healthcheck for application
      "tg_health_check_interval": 30, // Target group health parameter
      "tg_health_check_timeout": 25, // Target group health parameter
      "tg_health_check_unhealthy_threshold": 6, // Target group health parameter
      "tg_health_check_healthy_threshold": 2, // Target group health parameter
      "alb_security_groups": ["sg-04bdc51aaf93b05f7"], // Security group ID for ALB (existing or can be taken from VPC creation step)
      "alb_subnets": ["subnet-08520fda8edb84472", "subnet-0ccde9c2224e635ad"], // Public subnets ID (existing or can be taken from VPC creation step)
      "alb_listener_http": "True", // enable HTTP
      "alb_listener_https": "False", //disable HTTPS
      "lc_key_name": "check-code-test", // existin AWS key
      "lc_iam_instance_profile": "check-code-test", // name of existing instance profile to attach to ec2
      "lc_instance_type": "t2.small", //shape of instance
      "lc_root_block_device_volume_size": 12, //root volume device size
      "asg_health_check_grace_period": 600, // Autoscaling group parameter
      "asg_health_check_type": "EC2", // Autoscaling group parameter
      "asg_poll_delay": 300, // Autoscaling group parameter
      "asg_max_wait": 3600, // Autoscaling group parameter
      "asg_max_size": 1, // Max number of EC2 instances
      "asg_min_size": 1, // Min number of EC2 instances
      "asg_desired_capacity":1, // Current number of EC2 instances
      "asg_default_cooldown": 300, // Autoscaling group parameter
      "asg_name": "application-asg", // Name of Autoscaling group
      "asg_scaling_in_adjustment": "-1", // Scaling IN parameter
      "asg_scaling_out_adjustment": "5", // Scaling OUT parameter
      "asg_scaling_cooldown": 300, // Autoscaling group parameter
      "asg_vpc_zone_identifier": ["subnet-0aa1e60364e6b8566", "subnet-0e416194b6e1c936d"], // Private subnets ID (existing or can be taken from VPC creation step)
      "lc_image_id": "ami-0bbc25e23a7640b9b", // Amazon Image ID
      "lc_security_groups": ["sg-00d74b273a133b72f"], // Application instance Security group
      "cw_asg_alarms_in": [ // configuring CloudWatch alarm for ScaleIN
        {
            "name_suffix": "_CPUUtilization_SCALEIN",
            "comparison_operator": "LessThanOrEqualToThreshold",
            "evaluation_periods": 30,
            "metric_name": "CPUUtilization",
            "namespace": "AWS/EC2",
            "period": 60,
            "statistic": "Average",
            "threshold": 30,
            "actions_enabled": true,
            "alarm_description": "CPUUtilization",
            "treat_missing_data": "missing",
            "unit": "Percent"
          }
      ],
      "cw_asg_alarms_out": [ // configuring CloudWatch alarm for ScaleOUT
          {
            "name_suffix": "_CPUUtilization_SCALEOUT",
            "comparison_operator": "GreaterThanOrEqualToThreshold",
            "evaluation_periods": 5,
            "metric_name": "CPUUtilization",
            "namespace": "AWS/EC2",
            "period": 60,
            "statistic": "Average",
            "threshold": 70,
            "actions_enabled": true,
            "alarm_description": "CPUUtilization",
            "treat_missing_data": "missing",
            "unit": "Percent"
          }
      ]
    }
  }
}
```
**How to create application**

***Create environment for testing:***

```sh
git pull https://github.com/barmalry84/check_code.git
cd check_code
docker build -t little_framework:latest .
docker run -ti -v `pwd`:/tmp/little_framework -v ~/.aws:/root/.aws:ro little_framework:latest
```

*Make sure that you have AWS configuration file in ~/.aws or you have exported valid AWS_SECURITY_TOKEN AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN*

***Check framework:***

```sh
cd /tmp/little_framework
python3 small_framework.py -h
```

***(Optional) Fill vpc configuration file and create VPC in AWS account:***

```sh
python3 small_framework.py --action raise --config configuration/vpc.json --region eu-west-1 --service application --stack_definition vpc --env prod --version 1
```

***Fill application configuration file and run:***
```sh
python3 small_framework.py --action raise --config configuration/small_application.json --region eu-west-1 --service application --stack_definition tg,alb,asg,cwalarms --env prod --version 1
```

*Wait 5-10 minutes after terraform finishes. Check output for loadbalancer_dns_name or find it in AWS console. Open in browser http://loadbalancer_dns_name.*

**How to delete stack and VPC:**

***Delete application stack:***

***Find next terraform output variables in state file in s3 bucket or in output of stack creation and export them directly to the shell:***

```sh
export TF_VAR_target_group_arn=value
export TF_VAR_scaling_in_policy=value
export TF_VAR_scaling_out_policy=value

python3 small_framework.py --action destroy --config configuration/small_application.json --region eu-west-1 --service application --stack_definition asg,cwalarms,alb,tg --env prod --version 1
```

***(Optional) Delete VPC:***

```sh
python3 small_framework.py --action destroy --config configuration/vpc.json --region eu-west-1 --service application --stack_definition vpc --env prod --version 1
```

Please note that for every module separate terraform state file will be created under {bucket}/{environment}/{version} path.


