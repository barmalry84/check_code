variable "region"{

}
# Launch configuration
variable "lc_image_id"{

}
variable "lc_instance_type"{

}

variable "lc_ebs_optimized"{
  default = "false"
}

variable "lc_iam_instance_profile"{

}
variable "lc_key_name"{

}

variable "lc_root_block_device_volume_type"{
  default = "gp2"
}

variable "lc_root_block_device_volume_size"{
  default = 60
}

variable "lc_root_block_device_iops"{
  default = 0
}

variable "lc_security_groups"{
  type = "list"
}
variable "lc_vpc_classic_link_security_groups"{
  type = "list"
  default = []
}


# Autoscaling groups
variable "asg_name"{

}
variable "asg_min_size"{

}
variable "asg_max_size"{

}
variable "asg_desired_capacity"{

}
variable "asg_default_cooldown"{
  default=600
}
variable "asg_health_check_grace_period"{

}
variable "asg_health_check_type"{
  default = "EC2"
}

variable "asg_enabled_metrics"{
  default = ["GroupMinSize", "GroupMaxSize", "GroupDesiredCapacity", "GroupInServiceInstances", "GroupPendingInstances", "GroupStandbyInstances", "GroupTerminatingInstances", "GroupTotalInstances"]
  type = "list"
}

variable "asg_vpc_zone_identifier"{
  type = "list"
  default = []
}
variable "target_group_arn"{
}
variable "asg_termination_policies"{
  type = "list"
  default = ["OldestInstance"]
}
variable "service_name"{
  default = "Unknown"
}
variable "environment"{
  default = "Unknown"
}

variable "asg_wait_for_capacity_timeout"{
  default = 0
}

variable "asg_scaling_in_adjustment"{
}

variable "asg_scaling_out_adjustment"{
}

variable "asg_scaling_cooldown"{
}

# Additional tags:
variable asg_additional_tags {
  default = [
    {
      key = "EXTRA_TAG_KEY1"
      value = "EXTRA_TAG_VALUE1"
      propagate_at_launch = true
    }
  ]
}