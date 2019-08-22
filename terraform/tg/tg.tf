# target group creation

provider "aws" {
  region = "${var.region}"
}

resource "aws_alb_target_group" "targetgroup" {
  name       = "${var.tg_name}"
  port       = "${var.tg_port}"
  protocol   = "${var.tg_protocol}"
  vpc_id     = "${var.vpc_id}"
  slow_start = "${var.tg_slow_start}"

  health_check {
    healthy_threshold   = "${var.tg_health_check_healthy_threshold}"
    unhealthy_threshold = "${var.tg_health_check_unhealthy_threshold}"
    timeout             = "${var.tg_health_check_timeout}"
    path                = "${var.tg_health_check_path}"
    protocol            = "${var.tg_health_check_protocol}"
    port                = "${var.tg_health_check_port}"
    interval            = "${var.tg_health_check_interval}"
    matcher             = "${var.tg_health_check_matcher}"
  }

  stickiness {
    type    = "${var.tg_stickiness_type}"
    enabled = "${var.tg_stickiness_enabled}"
  }

}
