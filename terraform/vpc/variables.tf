variable "region" {
  description = "AWS region for VPC"
}

variable "aws_azs_no" {
  description = "number of AZs to return"
  default = "2"
}

variable "availability_zones" {
  description = "queried list of current AZs per region to deploy"
  default = "us-east-1a,us-east-1b"
}

variable "vpc_cidr" {
    description = "CIDR for the whole VPC"
    default = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
    description = "CIDRs for the Public Subnets"
}

variable "private_subnet_cidrs" {
    description = "CIDRs for the Private Subnets"
}

variable "elb_access_ports" {
    description = "ELB's port to access"
}

variable "elb_access_ranges" {
    description = "IP range to access ELB"
}

variable "elb_backend-port-rule1" {
    description = "Instance port for ingress ELB port1"
}
