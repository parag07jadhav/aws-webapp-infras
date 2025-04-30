// providers.tf
provider "aws" {
  region = var.aws_region
}

// vpc.tf
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  name = "webapp-vpc"
  cidr = "10.0.0.0/16"
  azs             = ["us-east-1a", "us-east-1b"]
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets = ["10.0.3.0/24", "10.0.4.0/24"]
  enable_nat_gateway = true
  single_nat_gateway = true
  tags = {
    Environment = "dev"
  }
} 

// eks.tf
module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = "webapp-eks"
  cluster_version = "1.29"
  subnets         = module.vpc.private_subnets
  vpc_id          = module.vpc.vpc_id
  enable_irsa     = true
  node_groups = {
    eks_nodes = {
      desired_capacity = 2
      max_capacity     = 3
      min_capacity     = 1
      instance_types   = ["t3.medium"]
    }
  }
} 

// ecs.tf
module "ecs" {
  source = "terraform-aws-modules/ecs/aws"
  name   = "webapp-ecs"
  vpc_id = module.vpc.vpc_id
  subnets = module.vpc.private_subnets
  capacity_providers = ["FARGATE"]
  services = {
    react-frontend = {
      cpu    = 256
      memory = 512
      container_definitions = file("../app/frontend/container-def.json")
    },
    node-backend = {
      cpu    = 256
      memory = 512
      container_definitions = file("../app/backend/container-def.json")
    }
  }
}

// mongodb.tf
resource "aws_security_group" "mongodb" {
  name        = "mongodb-sg"
  description = "Allow MongoDB access"
  vpc_id      = module.vpc.vpc_id
  ingress {
    from_port   = 27017
    to_port     = 27017
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "mongodb" {
  ami           = "ami-0c55b159cbfafe1f0" // Amazon Linux 2
  instance_type = "t3.micro"
  subnet_id     = module.vpc.private_subnets[0]
  vpc_security_group_ids = [aws_security_group.mongodb.id]
  user_data = file("../app/database/mongodb.sh")
  tags = {
    Name = "mongodb-instance"
  }
} 

// monitoring.tf
module "monitoring" {
  source  = "git::https://github.com/cloudposse/terraform-aws-ec2-cloudwatch-sns-alarms.git?ref=master"
  namespace = "webapp"
  stage     = "prod"
  name      = "alerts"
  alarm_cpu_threshold = 70
  alarm_memory_threshold = 80
}
