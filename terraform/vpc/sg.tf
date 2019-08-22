resource "aws_security_group" "elb-access-rul1" {

  name              = "ELB SG for port 80"
  description       = "Allow access to given ELBs ports"
  vpc_id            = "${aws_vpc.vpc_application.id}"

  ingress {
    from_port       = "${var.elb_backend-port-rule1}"
    to_port         = "${var.elb_backend-port-rule1}"
    protocol        = "tcp"
    cidr_blocks     = [ "${split(",", var.elb_access_ranges)}" ]
  }

  egress {
    from_port       = "0"
    to_port         = "0"
    protocol        = "-1"
    cidr_blocks     = [ "0.0.0.0/0" ]
  }
}

resource "aws_security_group" "backend" {

  name              = "Backend"
  description       = "Instances at private-subnets"
  vpc_id            = "${aws_vpc.vpc_application.id}"

  ingress {
    from_port       = "0"
    to_port         = "0"
    protocol        = "-1"
    cidr_blocks     = [ "${split(",", var.public_subnet_cidrs)}" ]
  }

  egress {
    from_port       = "0"
    to_port         = "0"
    protocol        = "-1"
    cidr_blocks     = [ "0.0.0.0/0" ]
  }
}

