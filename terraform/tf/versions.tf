terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.60"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.31"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }

}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "sre-takehome"
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  }
}

# Configured after the EKS cluster exists so kubectl-style resources (if any)
# can talk to it. We keep direct k8s resource management to a minimum here and
# prefer plain kubectl apply of the manifests in ../k8s for clarity/review, but
# the provider is wired up in case you want to manage the Secret via Terraform
# instead (see README "Wiring the app to RDS").
provider "kubernetes" {
  host                   = try(module.eks.cluster_endpoint, null)
  cluster_ca_certificate = try(base64decode(module.eks.cluster_certificate_authority_data), null)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args = [
      "eks", "get-token",
      "--cluster-name", try(module.eks.cluster_name, ""),
      "--region", var.aws_region,
    ]
  }
}
