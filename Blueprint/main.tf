provider "aws" {
  region = "us-east-1"
  alias  = "virginia"
}

data "aws_eks_cluster_auth" "this" {
  name = module.eks_cluster.cluster_name
}
provider "kubernetes" {
  host                   = module.eks_cluster.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks_cluster.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.this.token
}

provider "helm" {
  kubernetes {
    host                   = module.eks_cluster.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks_cluster.cluster_certificate_authority_data)
    token                  = data.aws_eks_cluster_auth.this.token
  }

}


data "aws_caller_identity" "current" {}

data "aws_ecrpublic_authorization_token" "token" {
  provider = aws.virginia
}

module "myapp_vpc" {
  source          = "../modules/vpc"
  name            = "${var.environment}-${var.vpc_name}"
  cidr            = var.vpc_cidr_block
  private_subnets = var.private_subnet_cidr_blocks
  public_subnets  = var.public_subnet_cidr_blocks
  azs             = var.vpc_availability_zones

  enable_nat_gateway     = var.vpc_enable_nat_gateway
  single_nat_gateway     = var.vpc_single_nat_gateway
  enable_dns_hostnames   = var.vpc_dns_hostname
  one_nat_gateway_per_az = var.one_nat_gateway_per_az
  enable_dns_support     = var.enable_dns_support
  tags                   = var.common_tags
  public_subnet_tags     = var.public_subnet_tags
  private_subnet_tags    = var.private_subnet_tags
}


# module "public_bastion_sg" {
#   depends_on  = [module.myapp_vpc]
#   source      = "../modules/security_group"
#   name        = "${var.environment}-${var.bastion_sg}"
#   description = "Security Group with SSH port open for everybody (IPv4 CIDR), egress ports are all world open"
#   vpc_id      = module.myapp_vpc.vpc_id
#   # Ingress Rules & CIDR Blocks
#   ingress_rules       = ["ssh-tcp"]
#   ingress_cidr_blocks = ["0.0.0.0/0"]
#   # Egress Rule - all-all open
#   egress_rules = ["all-all"]
# }


# module "ec2_basion_host" {
#   depends_on = [module.myapp_vpc, module.public_bastion_sg]
#   source     = "../modules/ec2_instance"

#   name              = "${var.environment}-${var.bastion_instance.name}"
#   ami               = var.bastion_instance.ami
#   instance_type     = var.bastion_instance.instance_type
#   root_block_device = var.bastion_instance.root_block_device != null ? var.bastion_instance.root_block_device : []
#   # key_name          = var.bastion_instance.key_name
#   #monitoring             = true
#   subnet_id              = element(module.myapp_vpc.public_subnets, 0)
#   vpc_security_group_ids = [module.public_bastion_sg.security_group_id]
#   # tags                   = var.common_tags
# }

# resource "aws_eip" "bastion_eip" {
#   depends_on = [module.ec2_basion_host, module.myapp_vpc]
#   tags       = var.common_tags
#   instance   = module.ec2_basion_host.id
#   domain     = "vpc"
# }


module "eks_cluster" {
  source = "../modules/eks"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version
  subnet_ids      = module.myapp_vpc.private_subnets
  vpc_id          = module.myapp_vpc.vpc_id


  enable_cluster_creator_admin_permissions = true
  cluster_endpoint_public_access           = var.cluster_endpoint_public_access
  # cluster_endpoint_public_access_cidrs = var.cluster_endpoint_public_access_cidrs


  # eks_managed_node_group_defaults = var.eks_managed_node_group_defaults

  eks_managed_node_groups = var.eks_managed_node_groups

  ## fargate_profiles = var.fargate_profiles

  # map_users = var.map_users

  # map_roles = var.map_roles

  # cluster_enabled_log_types = var.cluster_enabled_log_types
}






module "eks_blueprints_addons" {
  source  = "aws-ia/eks-blueprints-addons/aws"
  version = "1.16.3"

  cluster_name      = module.eks_cluster.cluster_name
  cluster_endpoint  = module.eks_cluster.cluster_endpoint
  oidc_provider_arn = module.eks_cluster.oidc_provider_arn
  cluster_version   = module.eks_cluster.cluster_version

  # EKS Managed Add-ons
  eks_addons = {
    # aws-ebs-csi-driver = {
    #   most_recent              = true
    #   service_account_role_arn = module.ebs_csi_driver_irsa.iam_role_arn
    # }
    coredns = {
      most_recent = true
      service_account_role_arn = module.coredns_irsa.role_arn

      timeouts = {
        create = "25m"
        delete = "10m"
      }
    }
    vpc-cni = {
      most_recent = true
      service_account_role_arn = module.vpc_cni_irsa.role_arn
    }
    kube-proxy = {
      most_recent              = true
      service_account_role_arn = module.kube_proxy_irsa.role_arn
    }
    # adot = {
    #   most_recent              = true
    #   service_account_role_arn = module.adot_irsa.iam_role_arn
    # }
  }


  # Add-ons
  # enable_metrics_server = true
  # enable_vpa            = true
  # enable_aws_efs_csi_driver           = true
  # enable_aws_for_fluentbit            = true
  # enable_aws_load_balancer_controller        = true
  # enable_cluster_autoscaler                  = true
  # enable_karpenter                           = true
  # karpenter_enable_instance_profile_creation = true
  # # ECR login required
  # karpenter = {
  #   repository_username = data.aws_ecrpublic_authorization_token.token.user_name
  #   repository_password = data.aws_ecrpublic_authorization_token.token.password
  # }
  ## enable only for self managed node groups
  # enable_aws_node_termination_handler = true
  # aws_node_termination_handler_asg_arns = [
  # for asg in module.eks_cluster.self_managed_node_groups : asg.autoscaling_group_arn]
  # Wait for all Cert-manager related resources to be ready

  # enable_external_dns = true
  # external_dns_route53_zone_arns = [
  #   "arn:aws:route53:::hostedzone/*",
  # ]

  # enable_cert_manager = true
  # cert_manager = {
  #   wait = true
  # }
  # enable_ingress_nginx = true
  # enable_argocd        = true
  # argocd = {
  #   set = [
  #     {
  #       name  = "server.service.type"
  #       value = "NodePort"
  #     }
  #   ]

  # }
  # enable_argo_rollouts  = true
  # enable_argo_workflows = true

}



module "vpc_cni_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"


  # oidc_provider_arn = module.eks_cluster.oidc_provider_arn
  role_name         = "${var.cluster_name}-vpc-cni-irsa"

  oidc_providers = {
    main = {
      provider_arn               = module.eks_cluster.oidc_provider_arn
      
    }
  }

  role_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  ]

  tags = var.tags
}

module "kube_proxy_irsa" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

  role_name         = "${var.cluster_name}-kube-proxy-irsa"
  
  oidc_providers = {
    main = {
      provider_arn               = module.eks_cluster.oidc_provider_arn
      
    }
  }

  role_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEKS_KubeProxy_Policy"
  ]

  tags = var.tags
}


module "coredns_irsa" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  role_name         = "${var.cluster_name}-coredns-irsa"


  oidc_providers = {
    main = {
      provider_arn               = module.eks_cluster.oidc_provider_arn
      
    }
  }

  role_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEKS_CoreDNS_Policy"
  ]

  tags = var.tags
}








