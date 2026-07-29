resource "random_password" "master" {
  length           = 24
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "aws_db_subnet_group" "this" {
  name       = "${var.name_prefix}-db-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name = "${var.name_prefix}-db-subnet-group"
  }
}

resource "aws_db_parameter_group" "this" {
  name   = "${var.name_prefix}-pg18"
  family = "postgres18"

  parameter {
    name  = "log_min_duration_statement"
    value = "1000" # log slow queries >1s — cheap observability win
  }
}

resource "aws_db_instance" "this" {
  identifier     = "${var.name_prefix}-db"
  engine         = "postgres"
  engine_version = var.db_engine_version
  instance_class = var.db_instance_class

  allocated_storage = var.db_allocated_storage
  storage_type      = "gp3"
  storage_encrypted = true

  db_name  = var.db_name
  username = var.db_username
  password = random_password.master.result
  port     = 5432

  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [var.rds_security_group_id]
  parameter_group_name   = aws_db_parameter_group.this.name

  publicly_accessible = false
  multi_az            = false # single-AZ: cost trade-off, see README

  backup_retention_period = 3
  skip_final_snapshot     = true # simplifies teardown for a take-home; would be false in production
  deletion_protection     = false

  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]

  tags = {
    Name = "${var.name_prefix}-db"
  }
}

# Store the generated credentials in Secrets Manager rather than in state
# output files or the repo. The app reads this at deploy time to build its
# Kubernetes Secret (see README "Wiring the app to RDS").
resource "aws_secretsmanager_secret" "db_credentials" {
  name = "${var.name_prefix}/rds/master-creds"
}

resource "aws_secretsmanager_secret_version" "db_credentials" {
  secret_id = aws_secretsmanager_secret.db_credentials.id
  secret_string = jsonencode({
    username = var.db_username
    password = random_password.master.result
    host     = aws_db_instance.this.address
    port     = 5432
    dbname   = var.db_name
  })
}
