variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "ap-southeast-1"
}

variable "instance_type" {
  description = "EC2 instance type (t3.small is recommended for Kind K8s to have enough memory)"
  type        = string
  default     = "t3.small"
}

variable "project_name" {
  description = "Prefix name for the project resources"
  type        = string
  
  default     = "k8s-1click"
}
