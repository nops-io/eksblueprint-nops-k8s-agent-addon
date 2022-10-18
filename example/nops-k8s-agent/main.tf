terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.10.0"
    }
  }
}

provider "aws" {
        region = "us-east-1"
}

provider "kubernetes" {
  host                   = module.eks_blueprints.eks_cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks_blueprints.eks_cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.this.token
}

provider "helm" {
  kubernetes {
    host                   = module.eks_blueprints.eks_cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks_blueprints.eks_cluster_certificate_authority_data)
    token                  = data.aws_eks_cluster_auth.this.token
  }
}

data "aws_eks_cluster_auth" "this" {
  name = module.eks_blueprints.eks_cluster_id
}


# get all available AZs in our region
data "aws_availability_zones" "available_azs" {
  state = "available"
}

# reserve Elastic IP to be used in our NAT gateway
resource "aws_eip" "nat_gw_elastic_ip" {
  vpc = true

  tags = {
    Name = "${var.cluster_name}-nat-eip"
  }
}

# create VPC using the official AWS module
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.14.0"

  name = "${var.name_prefix}-vpc"
  cidr = var.main_network_block
  azs  = data.aws_availability_zones.available_azs.names

  private_subnets = ["10.0.0.0/26", "10.0.0.64/26"]
  public_subnets = ["10.0.0.192/26", "10.0.0.128/26"]

  # enable single NAT Gateway to save some money
  # WARNING: this could create a single point of failure, since we are creating a NAT Gateway in one AZ only
  # feel free to change these options if you need to ensure full Availability without the need of running 'terraform apply'
  # reference: https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/2.44.0#nat-gateway-scenarios
  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false
  enable_dns_hostnames   = true
  reuse_nat_ips          = true
  external_nat_ip_ids    = [aws_eip.nat_gw_elastic_ip.id]

  # add VPC/Subnet tags required by EKS
  tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
  public_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                    = "1"
  }
  private_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"           = "1"
  }
}

# create security group to be used later by the ingress ALB
resource "aws_security_group" "alb" {
  name   = "${var.name_prefix}-alb"
  vpc_id = module.vpc.vpc_id

  ingress {
    description      = "http"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "https"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    "Name" = "${var.name_prefix}-alb"
  }
}

#************************************************

module "eks_blueprints" {
  source = "github.com/aws-ia/terraform-aws-eks-blueprints"

  # EKS CLUSTER
  cluster_version           = "1.21"
  cluster_name    = var.cluster_name
  vpc_id                    = module.vpc.vpc_id                     # Enter VPC ID
  private_subnet_ids        = module.vpc.private_subnets    # Enter Private Subnet IDs

  # EKS MANAGED NODE GROUPS
  managed_node_groups = {
    mg_m5 = {
      node_group_name = "managed-ondemand"
      instance_types  = ["t2.small"]
      max_size     = 3
      desired_size = 2
      min_size     = 2
      subnet_ids      = module.vpc.public_subnets
    }
  }
}

#  ##K8s Add-ons
module "eks_blueprints_kubernetes_addons" {
  source = "github.com/aws-ia/terraform-aws-eks-blueprints//modules/kubernetes-addons"

  eks_cluster_id       = module.eks_blueprints.eks_cluster_id
  eks_cluster_endpoint = module.eks_blueprints.eks_cluster_endpoint
  eks_oidc_provider    = module.eks_blueprints.oidc_provider
  eks_cluster_version  = module.eks_blueprints.eks_cluster_version


  enable_cert_manager = true	

  cert_manager_helm_config = {
    set_values = [
      {
        name  = "extraArgs[0]"
        value = "--enable-certificate-owner-ref=false"
      },
    ]
  }
### Enable nops agent ######################
  enable_nops_k8s_agent = true

  app_nops_k8s_collector_api_key = "xxxxxxxxxxxxxxxxxxxxx" #Api key of nops account 
  
  app_prometheus_server_endpoint = "http://prometheus-operator-kube-p-prometheus.nops-k8s-agent.svc.cluster.local:9090"
  app_nops_k8s_agent_clusterid  =  module.eks_blueprints.eks_cluster_id
  app_nops_k8s_collector_skip_ssl = ""
  app_nops_k8s_agent_prom_token = ""

  }

#---------------------------------------------------------------
# Nops Api key credentials resources
# Login to AWS secrets manager with the same role as Terraform to extract the nops api key with the secret name as "nops"
#---------------------------------------------------------------

resource "aws_secretsmanager_secret" "nops_apikey" {
  name                    = "nops_apikey"
  recovery_window_in_days = 0 # Set to zero for this example to force delete during Terraform destroy
}

resource "aws_secretsmanager_secret_version" "nops_apikey" {
  secret_id     = aws_secretsmanager_secret.nops_apikey.id
  secret_string = <<EOF
   {
    "nops_api_key": "xxxxxxxxxxxxxxxxxxxxxxxxx"
   }
}

data "aws_secretsmanager_secret_version" "nops_api_key_version" {
  secret_id = aws_secretsmanager_secret.nops_apikey.id

  depends_on = [aws_secretsmanager_secret_version.nops_apikey]
}
