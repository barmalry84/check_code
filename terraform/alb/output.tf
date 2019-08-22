output "loadbalancer_id" {
  value = "${aws_alb.loadbalancer.id}"
}

output "loadbalancer_name" {
  value = "${aws_alb.loadbalancer.name}"
}

output "loadbalancer_dns_name" {
  value = "${aws_alb.loadbalancer.dns_name}"
}

output "loadbalancer_zone_id" {
  value = "${aws_alb.loadbalancer.zone_id}"
}

output "loadbalancer_http_listener_id" {
  value = "${aws_alb_listener.http.*.id[0]}"
}
