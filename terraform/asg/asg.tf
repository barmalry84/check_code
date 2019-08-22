# Autoscaling group(VPC only)
provider "aws" {
  region = "${var.region}"
}


# Launch Configurations
resource "aws_launch_configuration" "launchconf" {

  name_prefix   = "${var.asg_name}-"
  image_id      = "${var.lc_image_id}"
  instance_type = "${var.lc_instance_type}"
  ebs_optimized = "${var.lc_ebs_optimized}"

  iam_instance_profile = "${var.lc_iam_instance_profile}"
  key_name             = "${var.lc_key_name}"
  security_groups      = "${var.lc_security_groups}"

  vpc_classic_link_security_groups = "${var.lc_vpc_classic_link_security_groups}"
  user_data                        = "${file("userdata")}"

  root_block_device {
    volume_type = "${var.lc_root_block_device_volume_type}"
    volume_size = "${var.lc_root_block_device_volume_size}"
    iops        = "${var.lc_root_block_device_iops}"
  }
}

# Create a new autoscaling group
resource "aws_autoscaling_group" "servergroup" {
  name = "${var.asg_name}"

  min_size         = "${var.asg_min_size}"
  max_size         = "${var.asg_max_size}"
  desired_capacity = "${var.asg_desired_capacity}"
  default_cooldown = "${var.asg_default_cooldown}"

  launch_configuration      = "${aws_launch_configuration.launchconf.name}"
  health_check_grace_period = "${var.asg_health_check_grace_period}"
  health_check_type         = "${var.asg_health_check_type}"
  vpc_zone_identifier       = "${var.asg_vpc_zone_identifier}"

  target_group_arns    = ["${var.target_group_arn}"]
  termination_policies = "${var.asg_termination_policies}"

  enabled_metrics     = "${var.asg_enabled_metrics}"

  wait_for_capacity_timeout = "${var.asg_wait_for_capacity_timeout}"

  tags = ["${concat(
      list(
        map("key", "APP_NAME", "value", "${var.service_name}", "propagate_at_launch", true),
        map("key", "Environment", "value", "${var.environment}", "propagate_at_launch", true),
      ),
      var.asg_additional_tags)
    }"]
}

resource "aws_autoscaling_policy" "ScaleIN" {
  name                   = "scalingIN_policy"
  scaling_adjustment     = "${var.asg_scaling_in_adjustment}"
  adjustment_type        = "ChangeInCapacity"
  cooldown               = "${var.asg_scaling_cooldown}"
  autoscaling_group_name = "${aws_autoscaling_group.servergroup.name}"
}

resource "aws_autoscaling_policy" "ScaleOUT" {
  name                   = "scalingOUT_policy"
  scaling_adjustment     = "${var.asg_scaling_out_adjustment}"
  adjustment_type        = "ChangeInCapacity"
  cooldown               = "${var.asg_scaling_cooldown}"
  autoscaling_group_name = "${aws_autoscaling_group.servergroup.name}"
}