# ALB Module with default forwarders
provider "aws" {
  region = "${var.region}"
}

# Create a new application load balancer
resource "aws_alb" "loadbalancer" {
  name               = "${var.alb_name}"
  security_groups    = "${var.alb_security_groups}"
  subnets            = "${var.alb_subnets}"
  internal           = "${var.alb_internal}"
  ip_address_type    = "${var.alb_ip_address_type}"
  idle_timeout       = "${var.alb_idle_timeout}"
  enable_http2       = "${var.alb_enable_http2}"

  access_logs {
    bucket        = "${var.alb_access_logs_bucket}"
    prefix        = "${var.alb_access_logs_prefix}"
    enabled       = "${var.alb_access_logs_enabled}"
  }

  enable_deletion_protection = "${var.alb_enable_deletion_protection}"

  tags {
    LOADBALANCER_NAME = "${var.alb_name}"
    APP_NAME = "${var.service_name}"
  }
}

resource "aws_alb_listener" "http" {
  count             = "${var.alb_listener_http ? 1 : 0}"
  load_balancer_arn = "${aws_alb.loadbalancer.arn}"
  port              = 80
  protocol          = "HTTP"

  default_action {
      target_group_arn = "${var.target_group_arn}"
      type             = "${var.alb_listener_default_action_type}"
  }
}

resource "aws_alb_listener" "https" {
  count             = "${var.alb_listener_https ? 1 : 0}"
  load_balancer_arn = "${aws_alb.loadbalancer.arn}"
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "${var.alb_listener_ssl_policy}"
  certificate_arn   = "${var.alb_listener_certificate_arn}"

  default_action {
      target_group_arn = "${var.target_group_arn}"
      type             = "${var.alb_listener_default_action_type}"
  }
}
