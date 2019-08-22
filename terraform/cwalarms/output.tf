output "cwalarm_arn_in" {
    value = ["${aws_cloudwatch_metric_alarm.cw_asg_alarms_in.*.arn}"]
}

output "cwalarm_id_in" {
    value = ["${aws_cloudwatch_metric_alarm.cw_asg_alarms_in.*.id}"]
}

output "cwalarm_arn_out" {
    value = ["${aws_cloudwatch_metric_alarm.cw_asg_alarms_out.*.arn}"]
}

output "cwalarm_id_out" {
    value = ["${aws_cloudwatch_metric_alarm.cw_asg_alarms_out.*.id}"]
}
