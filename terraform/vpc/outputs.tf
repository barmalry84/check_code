output "vpc_cidr" {
  value = "${var.vpc_cidr}"
}

output "vpc_id" {
  value = "${aws_vpc.vpc_application.id}"
}

output "public_subnet_ids" {
  value = "${join(",", aws_subnet.pub-subnet.*.id)}"
}

output "private_subnet_ids" {
  value = "${join(",", aws_subnet.priv-subnet.*.id)}"
}

output "nat_gw_eip" {
  value = "${join(",", aws_nat_gateway.nat-gw.*.public_ip)}"
}

output "nat_gw_priv_ip" {
  value = "${join(",", aws_nat_gateway.nat-gw.*.private_ip)}"
}

output "pub-rt.id" {
  value = "${aws_route_table.pub-rt.id}"
}

output "priv-rt" {
  value = "${join(",", aws_route_table.priv-rt.*.id)}"
}

