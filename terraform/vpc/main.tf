# VPC Layout

provider "aws" {
  region = "${var.region}"
}

resource "aws_vpc" "vpc_application" {
  cidr_block           = "${var.vpc_cidr}"
  enable_dns_hostnames = true
  enable_dns_support   = true
}

resource "aws_subnet" "pub-subnet" {
  count = "${var.aws_azs_no}"
  vpc_id = "${aws_vpc.vpc_application.id}"
  cidr_block = "${element( split(",", var.public_subnet_cidrs), count.index)}"
  availability_zone = "${element( split(",", var.availability_zones) , count.index)}"
  map_public_ip_on_launch = false

  lifecycle {
    ignore_changes = [ "availability_zone"]
  }
}

resource "aws_subnet" "priv-subnet" {
  count = "${var.aws_azs_no}"
  vpc_id = "${aws_vpc.vpc_application.id}"
  cidr_block = "${element( split(",", var.private_subnet_cidrs), count.index)}"
  availability_zone = "${element( split(",", var.availability_zones) , count.index)}"
  map_public_ip_on_launch = false

    lifecycle {
      ignore_changes = [ "availability_zone"]
    }
}

## Create EIPs for each nat-gw per AZ
resource "aws_eip" "nat-gw-eib" {
  count = "${var.aws_azs_no}"
  vpc   = true
}

resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.vpc_application.id}"

}

## auto-iterate on each EIP per num_of_AZ
resource "aws_nat_gateway" "nat-gw" {
  depends_on = ["aws_internet_gateway.igw"]
  count = "${var.aws_azs_no}"
  allocation_id = "${element(aws_eip.nat-gw-eib.*.id, count.index)}"
  subnet_id     = "${element(aws_subnet.pub-subnet.*.id, count.index)}"
}
