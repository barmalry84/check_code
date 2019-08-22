# CW ASG alarm creation from existing metric with adding mandatory Alarm actions

provider "aws" {
  region = "${var.region}"
}

resource "aws_cloudwatch_metric_alarm" "cw_asg_alarms_in" {

  count                         = "${length(var.cw_asg_alarms_in)}"

  alarm_name                    = "${var.asg_name}${lookup(var.cw_asg_alarms_in[count.index], "name_suffix")}"
  comparison_operator           = "${lookup(var.cw_asg_alarms_in[count.index], "comparison_operator")}"
  evaluation_periods            = "${lookup(var.cw_asg_alarms_in[count.index], "evaluation_periods")}"
  metric_name                   = "${lookup(var.cw_asg_alarms_in[count.index], "metric_name")}"
  namespace                     = "${lookup(var.cw_asg_alarms_in[count.index], "namespace")}"
  period                        = "${lookup(var.cw_asg_alarms_in[count.index], "period")}"
  statistic                     = "${lookup(var.cw_asg_alarms_in[count.index], "statistic")}"
  threshold                     = "${lookup(var.cw_asg_alarms_in[count.index], "threshold")}"
  actions_enabled               = "${lookup(var.cw_asg_alarms_in[count.index], "actions_enabled")}"
  alarm_description             = "${lookup(var.cw_asg_alarms_in[count.index], "alarm_description")}"
  treat_missing_data            = "${lookup(var.cw_asg_alarms_in[count.index], "treat_missing_data")}"
  unit                          = "${lookup(var.cw_asg_alarms_in[count.index], "unit")}"
  alarm_actions                 = ["${var.scaling_in_policy}"]
  dimensions {
    AutoScalingGroupName = "${var.asg_name}"
  }

}

resource "aws_cloudwatch_metric_alarm" "cw_asg_alarms_out" {

  count                         = "${length(var.cw_asg_alarms_out)}"

  alarm_name                    = "${var.asg_name}${lookup(var.cw_asg_alarms_out[count.index], "name_suffix")}"
  comparison_operator           = "${lookup(var.cw_asg_alarms_out[count.index], "comparison_operator")}"
  evaluation_periods            = "${lookup(var.cw_asg_alarms_out[count.index], "evaluation_periods")}"
  metric_name                   = "${lookup(var.cw_asg_alarms_out[count.index], "metric_name")}"
  namespace                     = "${lookup(var.cw_asg_alarms_out[count.index], "namespace")}"
  period                        = "${lookup(var.cw_asg_alarms_out[count.index], "period")}"
  statistic                     = "${lookup(var.cw_asg_alarms_out[count.index], "statistic")}"
  threshold                     = "${lookup(var.cw_asg_alarms_out[count.index], "threshold")}"
  actions_enabled               = "${lookup(var.cw_asg_alarms_out[count.index], "actions_enabled")}"
  alarm_description             = "${lookup(var.cw_asg_alarms_out[count.index], "alarm_description")}"
  treat_missing_data            = "${lookup(var.cw_asg_alarms_out[count.index], "treat_missing_data")}"
  unit                          = "${lookup(var.cw_asg_alarms_out[count.index], "unit")}"
  alarm_actions                 = ["${var.scaling_out_policy}"]
  dimensions {
    AutoScalingGroupName = "${var.asg_name}"
  }

}


