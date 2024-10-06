provider "aws" {
  region = "us-east-1"
  alias  = "virginia"
}

# data "aws_eks_cluster_auth" "this" {
#   name = module.eks_cluster.cluster_name
# }
# provider "kubernetes" {
#   host                   = module.eks_cluster.cluster_endpoint
#   cluster_ca_certificate = base64decode(module.eks_cluster.cluster_certificate_authority_data)
#   token                  = data.aws_eks_cluster_auth.this.token
# }

# provider "helm" {
#   kubernetes {
#     host                   = module.eks_cluster.cluster_endpoint
#     cluster_ca_certificate = base64decode(module.eks_cluster.cluster_certificate_authority_data)
#     token                  = data.aws_eks_cluster_auth.this.token
#   }

# }


data "aws_caller_identity" "current" {}

# data "aws_ecrpublic_authorization_token" "token" {
#   provider = aws.virginia
# }
#####
# module "myapp_vpc" {
#   source          = "../modules/vpc"
#   name            = "${var.environment}-${var.vpc_name}"
#   cidr            = var.vpc_cidr_block
#   private_subnets = var.private_subnet_cidr_blocks
#   public_subnets  = var.public_subnet_cidr_blocks
#   azs             = var.vpc_availability_zones

#   enable_nat_gateway     = var.vpc_enable_nat_gateway
#   single_nat_gateway     = var.vpc_single_nat_gateway
#   enable_dns_hostnames   = var.vpc_dns_hostname
#   one_nat_gateway_per_az = var.one_nat_gateway_per_az
#   enable_dns_support     = var.enable_dns_support
#   tags                   = var.common_tags
#   public_subnet_tags     = var.public_subnet_tags
#   private_subnet_tags    = var.private_subnet_tags
# }



# module "eks_cluster" {
#   source = "../modules/eks"

#   cluster_name    = var.cluster_name
#   cluster_version = var.cluster_version
#   subnet_ids      = module.myapp_vpc.private_subnets
#   vpc_id          = module.myapp_vpc.vpc_id


#   enable_cluster_creator_admin_permissions = true
#   cluster_endpoint_public_access           = var.cluster_endpoint_public_access
  


#   eks_managed_node_groups = var.eks_managed_node_groups

# }

# module "eks_auth" {
#   source = "aidanmelen/eks-auth/aws"
#   eks    = module.eks_cluster
# ### user
#   map_roles = [
#     {
#       rolearn  = "arn:aws:iam::058264357476:role/AdministratorAccess-Role"
#       username = "devopsadmin"
#       groups   = ["system:masters"]
#     }
#   ]

# }






# module "eks_blueprints_addons" {
#   source  = "aws-ia/eks-blueprints-addons/aws"
#   version = "1.16.3"

#   cluster_name      = module.eks_cluster.cluster_name
#   cluster_endpoint  = module.eks_cluster.cluster_endpoint
#   oidc_provider_arn = module.eks_cluster.oidc_provider_arn
#   cluster_version   = module.eks_cluster.cluster_version

#   # EKS Managed Add-ons
#   eks_addons = {
    
#     coredns = {
#       most_recent = true
      
#       timeouts = {
#         create = "25m"
#         delete = "10m"
#       }
#     }
#     vpc-cni = {
#       most_recent = true
     
#     }
#     kube-proxy = {
#       most_recent              = true
      
#     } 
#   }
#    depends_on = [
#     module.eks_cluster,
#     module.eks_cluster.eks_managed_node_groups
#   ]
# }



