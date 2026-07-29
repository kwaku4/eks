inputs = {
  aws_region          = "us-east-1"
  environment         = "dev"
  cluster_name        = "dev"

  vpc_cidr            = "10.10.0.0/16"
  az_count            = 2
  public_subnets  = ["10.10.1.0/24", "10.10.2.0/24"]
  private_subnets = ["10.10.3.0/24", "10.10.4.0/24"]

  node_instance_types = ["t3.small"]
  node_desired_size   = 2
  node_min_size       = 1
  node_max_size       = 3
  node_capacity_type  = "ON_DEMAND"

  db_engine_version = "18.3"
  db_instance_class = "db.t4g.micro"

  alert_email = ""
}
