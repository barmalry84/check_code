# Defaults
variable "region"{
}

variable "cw_asg_alarms_in"{
    type="list"
    default=[]
}

variable "cw_asg_alarms_out"{
    type="list"
    default=[]
}

variable "asg_name"{
}

variable "scaling_in_policy"{
}

variable "scaling_out_policy"{
}