variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-east-1"
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "dev"
}

variable "environment" {
  description = "Environment name, used in tags and resource naming"
  type        = string
  default     = "dev"
}

variable "app_name" {
  description = "Name of the application, used in resource naming"
  type        = string
}

variable "project_name" {
  description = "Short project name used as a prefix for resource names"
  type        = string
  default     = "sre-takehome"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnets" {
  description = "List of public subnet CIDRs"
  type        = list(string)
  default     = []
}

variable "private_subnets" {
  description = "List of private subnet CIDRs"
  type        = list(string)
  default     = []
}

variable "az_count" {
  description = "Number of availability zones to spread subnets across"
  type        = number
  default     = 2
}

variable "cluster_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
  default     = "1.30"
}

variable "node_instance_types" {
  description = "Instance types for the EKS managed node group (cost-minimized)"
  type        = list(string)
  default     = ["t3.small"]
}

variable "node_desired_size" {
  description = "Desired number of worker nodes"
  type        = number
  default     = 2
}

variable "node_min_size" {
  description = "Minimum number of worker nodes"
  type        = number
  default     = 1
}

variable "node_max_size" {
  description = "Maximum number of worker nodes"
  type        = number
  default     = 3
}

variable "node_capacity_type" {
  description = "ON_DEMAND or SPOT"
  type        = string
  default     = "ON_DEMAND"
}

variable "db_engine_version" {
  description = "Postgres engine version for RDS"
  type        = string
  default     = "16.4"
}

variable "db_instance_class" {
  description = "RDS instance class (cost-minimized)"
  type        = string
  default     = "db.t4g.micro"
}

variable "db_allocated_storage" {
  description = "RDS allocated storage in GB"
  type        = number
  default     = 20
}

variable "db_name" {
  description = "Initial database name"
  type        = string
  default     = "demoapp"
}

variable "db_username" {
  description = "Master username for RDS"
  type        = string
  default     = "demoapp_admin"
}

variable "alert_email" {
  description = "Email address to subscribe to the CloudWatch alerts SNS topic. Leave empty to skip subscription."
  type        = string
  default     = ""
}
