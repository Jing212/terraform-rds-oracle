#####################
# VPC + 公网子网/IGW #
#####################
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "6.4.0" # vpc 模块 6.x 需要 AWS Provider v6

  name = "${var.PJPrefix}-${var.EnvType}-vpc"
  cidr = "10.0.0.0/16"

  azs = ["us-east-1a", "us-east-1b"]

  # 公有子网（路由到 IGW）
  public_subnets = ["10.0.0.0/24", "10.0.1.0/24"]

  create_igw           = true
  enable_nat_gateway   = false
  enable_dns_support   = true
  enable_dns_hostnames = true
}

################
# RDS 安全组   #
################
resource "aws_security_group" "rds" {
  name        = "${var.PJPrefix}-${var.EnvType}-rds-sg"
  description = "Allow Oracle 1521 from my IP"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "Oracle from my IP"
    from_port   = 1521
    to_port     = 1521
    protocol    = "tcp"
    cidr_blocks = [var.my_ip_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#############
# RDS Oracle #
#############
module "db" {
  source  = "terraform-aws-modules/rds/aws"
  version = "6.13.0"

  identifier = "${var.PJPrefix}-${var.EnvType}-oracle"

  # 选 SE2（比 EE 便宜）
  engine               = "oracle-se2"
  family               = "oracle-se2-19"
  major_engine_version = "19"

  # 没有自带 Oracle 许可时，选 License Included（最省心，入门成本最低）
  license_model = "license-included"

  # 尽量小的规格（Oracle RDS 通常能用的最小是 db.t3.small）
  instance_class    = var.instance_class    # 建议 "db.t3.small"
  allocated_storage = var.allocated_storage # 建议 20（GiB）
  storage_type      = "gp3"                 # 比 gp2 便宜

  # 基础连接
  username = var.db_username
  password = var.db_password
  port     = 1521
  db_name  = "ORCL"

  # 单 AZ、可公网直连（你要体验最省事）
  multi_az               = false
  publicly_accessible    = true
  create_db_subnet_group = true
  subnet_ids             = module.vpc.public_subnets
  vpc_security_group_ids = [aws_security_group.rds.id]

  # 全部省钱项（教学用）
  backup_retention_period      = 0 # 关自动备份（演示环境）
  monitoring_interval          = 0 # 关增强监控
  performance_insights_enabled = false
  deletion_protection          = false
  skip_final_snapshot          = true
  apply_immediately            = true

  # 不要开自动扩容（别设置 max_allocated_storage）
}