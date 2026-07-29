terraform {
  source = "${get_parent_terragrunt_dir()}/tf"
}

locals {
  common_vars      = read_terragrunt_config(find_in_parent_folders("common.hcl")).inputs
  environment_vars = read_terragrunt_config(find_in_parent_folders("environment.hcl")).inputs
}

remote_state {
  backend = "s3"

  config = {
    bucket  = "sre-takehome-tfstate-323232"
    key     = "${path_relative_to_include()}/terraform.tfstate"
    region  = local.environment_vars.aws_region
    encrypt = true
  }
}

inputs = merge(
  local.common_vars,
  local.environment_vars
)

