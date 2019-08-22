resource "aws_network_acl" "dmz-acl" {
  vpc_id = "${aws_vpc.vpc_application.id}"
  subnet_ids = ["${aws_subnet.pub-subnet.*.id}"]

  ingress = {
    protocol = "all"
    rule_no = 100
    action = "allow"
    cidr_block =  "0.0.0.0/0"
    from_port = 0
    to_port = 0
  }

  egress = {
    protocol = "all"
    rule_no = 100
    action = "allow"
    cidr_block =  "0.0.0.0/0"
    from_port = 0
    to_port = 0
  }
}

resource "aws_network_acl" "priv-subnets-acl" {
  vpc_id = "${aws_vpc.vpc_application.id}"
  subnet_ids = ["${aws_subnet.priv-subnet.*.id}"]

  ingress = {
    protocol = "all"
    rule_no = 100
    action = "allow"
    cidr_block =  "0.0.0.0/0"
    from_port = 0
    to_port = 0
  }

  egress = {
    protocol = "all"
    rule_no = 100
    action = "allow"
    cidr_block =  "0.0.0.0/0"
    from_port = 0
    to_port = 0
  }
}
