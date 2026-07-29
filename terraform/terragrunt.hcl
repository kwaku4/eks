terraform {
  source = "${get_parent_terragrunt_dir()}/tf"
}

locals {
  common_vars      = read_terragrunt_config(find_in_parent_folders("common.hcl")).inputs
  environment_vars = read_terragrunt_config(find_in_parent_folders("environment.hcl")).inputs
}

remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    bucket         = "sre-takehome-tfstate-211125593418"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = local.environment_vars.aws_region
    encrypt        = true
    dynamodb_table = "sre-takehome-tf-locks"
  }
}

inputs = merge(
  local.common_vars,
  local.environment_vars
)

