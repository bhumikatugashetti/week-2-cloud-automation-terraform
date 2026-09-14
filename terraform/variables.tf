variable "aws_region" {
  description = "AWS region for the deployment."
  type        = string
  default     = "ap-south-1"
}

variable "project_name" {
  description = "Project name used in resource names."
  type        = string
  default     = "yuva-week2-cloud-app"
}

variable "environment" {
  description = "Environment name."
  type        = string
  default     = "dev"
}

variable "vpc_cidr" {
  description = "CIDR range for the VPC."
  type        = string
  default     = "10.20.0.0/16"
}

variable "web_instance_type" {
  description = "EC2 instance type for web tier."
  type        = string
  default     = "t3.micro"
}

variable "app_instance_type" {
  description = "EC2 instance type for application tier."
  type        = string
  default     = "t3.micro"
}

variable "web_desired_capacity" { type = number default = 2 }
variable "web_min_size"         { type = number default = 2 }
variable "web_max_size"         { type = number default = 4 }
variable "app_desired_capacity" { type = number default = 2 }
variable "app_min_size"         { type = number default = 2 }
variable "app_max_size"         { type = number default = 4 }

variable "db_name" {
  type    = string
  default = "appdb"
}

variable "db_username" {
  type    = string
  default = "appadmin"
}

variable "db_password" {
  description = "Database password. Pass with TF_VAR_db_password or a tfvars file; never commit secrets."
  type        = string
  sensitive   = true
}

variable "db_instance_class" {
  description = "RDS instance class."
  type        = string
  default     = "db.t3.micro"
}

variable "db_allocated_storage" {
  description = "Initial RDS storage in GiB."
  type        = number
  default     = 20
}
