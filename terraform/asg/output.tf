output "lc_name" {
  value = "${aws_launch_configuration.launchconf.name}"
}

output "asg_name" {
  value = "${aws_autoscaling_group.servergroup.name}" 
}

output "scaling_in_policy" {
  value = "${aws_autoscaling_policy.ScaleIN.arn}"
}

output "scaling_out_policy" {
  value = "${aws_autoscaling_policy.ScaleOUT.arn}"
}
