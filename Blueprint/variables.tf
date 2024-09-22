# VPC Input Variables

# VPC Name
variable "vpc_name" {
  description = "VPC Name"
  type        = string
  default     = "my-k3s-vpc"
}

# VPC CIDR Block
variable "vpc_cidr_block" {
  description = "VPC CIDR Block"
  type        = string
  default     = "10.0.0.0/16"
}

# VPC Availability Zones

variable "vpc_availability_zones" {
  description = "VPC Availability Zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}


# VPC Public Subnets
variable "public_subnet_cidr_blocks" {
  description = "VPC Public Subnets"
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24"]
}

# VPC Private Subnets
variable "private_subnet_cidr_blocks" {
  description = "VPC Private Subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}


# VPC Enable NAT Gateway (True or False) 
variable "vpc_enable_nat_gateway" {
  description = "Enable NAT Gateways for Private Subnets Outbound Communication"
  type        = bool
  default     = true
}

# VPC Single NAT Gateway (True or False)
variable "vpc_single_nat_gateway" {
  description = "Enable only single NAT Gateway in one Availability Zone to save costs during our demos"
  type        = bool
  default     = true
}

variable "vpc_dns_hostname" {
  description = "Enable dns hostname"
  type        = bool
  default     = true
}


# variable "vpc_tags" {
#   type = map(string)
#   default = {
#     "kubernetes.io/cluster/myapp-eks-cluster" = "shared"
#   }
# }

variable "public_subnet_tags" {
  type = map(string)
  default = {
    "kubernetes.io/cluster/myapp-eks-cluster" = "shared"
    "kubernetes.io/role/elb"                  = "1"
  }
}

variable "private_subnet_tags" {
  type = map(string)
  default = {
    "kubernetes.io/cluster/myapp-eks-cluster" = "shared"
    "kubernetes.io/role/internal-elb"         = "1"
  }
}

variable "one_nat_gateway_per_az" {
  description = "Deploy nat gateway per az"
  type        = bool
  default     = false
}

variable "enable_dns_support" {
  description = "Enable dns support"
  type        = bool
  default     = true
}


# Security group variables

variable "bastion_sg" {
  description = "Bastion instance security group Name"
  type        = string
  default     = "bastion-sg"
}





# EC2 vairables 

variable "bastion_instance" {
  description = "Configuration for a bastion instance."
  type = object({
    name          = string
    instance_type = string
    ami           = string
    # key_name      = string
    root_block_device = optional(list(object({
      encrypted   = optional(bool)
      volume_type = optional(string)
      throughput  = optional(number)
      volume_size = optional(number)
      tags        = optional(map(string))
    })))
  })
}

variable "cluster_name" {
  type = string
}

variable "cluster_version" {
  type    = string
  default = "1.29"
}


variable "enable_irsa" {
  type = bool
}


# variable "eks_managed_node_group_defaults" {
#   type = any
# }

variable "eks_managed_node_groups" {
  type = map(any)
}

variable "cluster_endpoint_public_access" {
  description = "Indicates whether or not the Amazon EKS public API server endpoint is enabled."
  type        = bool
  default     = false
}

variable "cluster_endpoint_public_access_cidrs" {
  description = "CIDR blocks that should be granted public access to the S3 bucket"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

# variable "fargate_profiles" {
#   type = optional(map(any))
# }

# variable "cluster_enabled_log_types" {
#   type = list(string)
# }


# variable "map_users" {
#   description = "Additional IAM users to add to the aws-auth configmap."
#   type = list(object({
#     userarn  = string
#     username = string
#     groups   = list(string)
#   }))
# }

# variable "map_roles" {
#   description = "Additional IAM roles to add to the aws-auth configmap."
#   type = list(object({
#     rolearn  = string
#     username = string
#     groups   = list(string)
#   }))
# }


