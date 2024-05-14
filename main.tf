terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

module "subnet" {
  source = "./modules/subnet"
}

module "iam" {
  source = "./modules/iam"
}

resource "aws_security_group" "eks_cluster_sg" {
  vpc_id = module.subnet.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "EKS Cluster Security Group"
  }
}

resource "aws_eks_cluster" "my_cluster" {
  name     = "DefaultCluster"
  role_arn = module.iam.eks_cluster_role_arn
  version  = "1.29" # 1.30 is not supported on EKS...

  vpc_config {
    subnet_ids         = module.subnet.subnet_ids
    security_group_ids = ["${aws_security_group.eks_cluster_sg.id}"]
  }
}

resource "aws_eks_node_group" "my_node_group" {
  cluster_name    = aws_eks_cluster.my_cluster.name
  node_group_name = "DefaultNodeGroup"
  node_role_arn   = module.iam.eks_node_role_arn
  subnet_ids      = module.subnet.subnet_ids
  ami_type        = "AL2_ARM_64"   # otherwise defaults to x86_64
  instance_types  = ["m7g.medium"] # smallest Gravitron 3 instance
  capacity_type   = "ON_DEMAND"    # money could be saved with Spot
  scaling_config {
    desired_size = 2
    max_size     = 4
    min_size     = 2
  }
}
