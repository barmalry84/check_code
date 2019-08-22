variable "region"{

}
variable "tg_name"{

}
variable "tg_port"{
   default=80
}
variable "tg_protocol"{
   default="HTTP"
}
variable "vpc_id"{

}
variable "tg_slow_start"{
   default=0
}
variable "tg_health_check_healthy_threshold"{
   default=2
}
variable "tg_health_check_unhealthy_threshold"{
   default=6
}
variable "tg_health_check_timeout"{
   default=25
}
variable "tg_health_check_matcher"{
   default=200
}
variable "tg_health_check_path"{
   default="/index.html"
}
variable "tg_health_check_protocol"{
   default="HTTP"
}
variable "tg_health_check_port"{
   default=80
}
variable "tg_health_check_interval"{
   default=30
}
variable "tg_stickiness_type"{
   default="lb_cookie"
}
variable "tg_stickiness_enabled"{
   default="false"
}
