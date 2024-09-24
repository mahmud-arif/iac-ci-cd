terraform {
  required_version = "~>1.7.4"
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.40.0"
    }
    helm = {
      source = "hashicorp/helm"
      #version = "2.5.1"
      version = "~> 2.5"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.11"
    }
  }

  backend "s3" {
    bucket         = "my-iac-states"
    key            = "prod/terraform.tfstate"
    region         = "us-east-1"
    # dynamodb_table = "dev"
    # encrypt        = true
  }
}





provider "aws" {
  region = "us-east-1"
  # profile = "kartat-aws-account"

}

locals {
  project_name = "kartat"
  # key_name     = "terraform-iqdx"
  environment = "prod-t"
  common_tags = {
    environment = local.environment
    Name        = local.project_name
  }
  eks_cluster_name = "${local.project_name}-${local.environment}-cluster"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

data "aws_availability_zones" "available" {}



module "prod" {
  environment  = local.environment
  common_tags  = local.common_tags
  project_name = local.project_name
  ## vpc settings
  source                     = "../../Blueprint"
  vpc_name                   = "my-vpc"
  vpc_cidr_block             = "10.1.0.0/16"
  vpc_availability_zones     = slice(data.aws_availability_zones.available.names, 0, 2)
  private_subnet_cidr_blocks = ["10.1.1.0/24", "10.1.2.0/24"]
  public_subnet_cidr_blocks  = ["10.1.4.0/24", "10.1.5.0/24"]
  vpc_enable_nat_gateway     = true
  vpc_single_nat_gateway     = true
  enable_dns_support         = true
  vpc_dns_hostname           = true
  # vpc_tags = {
  #   "kubernetes.io/cluster/${local.eks_cluster_name}" = "shared"
  # }

  public_subnet_tags = {

    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
    "karpenter.sh/discovery"          = local.eks_cluster_name
  }

  ## bastion sg Settings
  bastion_sg = "bastion-sg"

  ## bastion host settings
  bastion_instance = {
    name          = "bastion-host"
    instance_type = "t3.small"
    ami           = data.aws_ami.ubuntu.id
    # key_name      = local.key_name
    root_block_device = [{
      volume_size = 10
    }]
  }


  # EKS settings 
  cluster_name                         = local.eks_cluster_name
  cluster_version                      = 1.29
  enable_irsa                          = true
  cluster_endpoint_public_access       = true
  cluster_endpoint_public_access_cidrs = ["0.0.0.0/0"]

  # eks_managed_node_group_defaults = {
  #   ami_type       = "AL2_x86_64"
  #   instance_types = ["m6i.large", "m5.large", "m5n.large", "m5zn.large"]
  # }
  eks_managed_node_groups = {
    dev = {
      min_size     = 2
      max_size     = 3
      desired_size = 2

      instance_type = ["t3.medium"]
    }
  }
}
