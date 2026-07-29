output "vpc_id" {
  value = module.vpc.vpc_id
}

output "cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "rds_endpoint" {
  value = module.rds.db_endpoint
}

output "rds_secret_arn" {
  description = "Secrets Manager ARN holding RDS master credentials — fetch with `aws secretsmanager get-secret-value`"
  value       = module.rds.secret_arn
}

output "configure_kubectl" {
  value = "aws eks update-kubeconfig --name ${module.eks.cluster_name} --region ${var.aws_region}"
}

output "ecr_repository_url" {
  description = "ECR repository URL for the demo application"
  value       = aws_ecr_repository.demo_app.repository_url
}

