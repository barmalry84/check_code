## Public Route to Internet
resource "aws_route_table" "pub-rt" {
  vpc_id = "${aws_vpc.vpc_application.id}"
   route {
     cidr_block = "0.0.0.0/0"
     gateway_id = "${aws_internet_gateway.igw.id}"
   }
}

## Associate pub_route_table per AZ/Subnet
resource "aws_route_table_association" "pub-rtassoc" {
  count = "${var.aws_azs_no}"
  subnet_id = "${element(aws_subnet.pub-subnet.*.id, count.index)}"
  route_table_id = "${aws_route_table.pub-rt.id}"
}

# Route for each subnet to its nat-gateway
resource "aws_route_table" "priv-rt" {
  count = "${var.aws_azs_no}"
  vpc_id = "${aws_vpc.vpc_application.id}"
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = "${element(aws_nat_gateway.nat-gw.*.id, count.index)}"
  }
}

# Associate private_route_table per AZ/Subnet
resource "aws_route_table_association" "priv-rtassoc" {
  count = "${var.aws_azs_no}"
  subnet_id = "${element(aws_subnet.priv-subnet.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.priv-rt.*.id, count.index)}"
}

