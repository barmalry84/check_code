output "target_group_id" {
  value = "${aws_alb_target_group.targetgroup.id}"
}

output "target_group_arn" {
  value = "${aws_alb_target_group.targetgroup.arn}"
}
