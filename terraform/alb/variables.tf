variable "region" {
}

variable "alb_name" {
}

variable "service_name"{

}

variable "alb_security_groups" {
  type = "list"
}

variable "alb_subnets" {
  type = "list"
}

variable "alb_internal" {
  default = "false"
}
variable "alb_ip_address_type" {
  default = "ipv4"
}
variable "alb_idle_timeout" {
  default = 60
}
variable "alb_access_logs_bucket" {
    default = "false"
}

variable "alb_access_logs_prefix" {
    default = "false"
}

variable "alb_access_logs_enabled" {
   default = "false"
}

variable "alb_listener_http" {
   default = "true"
}

variable "alb_listener_https" {
   default = "false"
}

variable "alb_enable_deletion_protection" {
   default = "false"
}

variable "alb_enable_http2" {
   default = "true"
}

variable "target_group_arn"{
}

variable "alb_listener_default_action_type" {
    default = "forward"
}

variable "alb_listener_ssl_policy" {
    default = "ELBSecurityPolicy-TLS-1-2-2017-01"
}

variable "alb_listener_certificate_arn" {
    default = "set:certificate:path:or:certarn"
}
