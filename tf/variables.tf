######################### General #########################
variable "region" {
  description = "Region to deploy"
  type        = string
  default     = "eu-west-1"
}

variable "project" {
  description = "Name of Project"
  default     = "abz"
}
