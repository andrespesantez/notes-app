# ============================================
# Notes App - Terraform Main Configuration
# ============================================
# Infraestructura AWS OPTIMIZADA PARA COSTOS MÍNIMOS
# - EKS con nodos t3.micro (Free Tier elegible)
# - RDS db.t3.micro (Free Tier: 750 hrs/mes primer año)
# - NAT Gateway único
# - Sin Multi-AZ en RDS
# ============================================

terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
  }

  # Backend S3 (descomentar para producción)
  # backend "s3" {
  #   bucket = "notes-app-terraform-state"
  #   key    = "eks/terraform.tfstate"
  #   region = "us-east-1"
  # }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "notes-app"
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  }
}

# Providers para Kubernetes y Helm (se configuran después de EKS)
provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
  }
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
    }
  }
}

# ============================================
# Variables
# ============================================

variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "production"
}

variable "db_username" {
  description = "Database username"
  type        = string
  default     = "notes_user"
}

variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}

variable "dockerhub_username" {
  description = "Docker Hub username for image references"
  type        = string
}

# ============================================
# Data Sources
# ============================================

data "aws_availability_zones" "available" {
  state = "available"
}

# ============================================
# VPC
# ============================================

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "notes-app-vpc"
  cidr = "10.0.0.0/16"

  azs             = slice(data.aws_availability_zones.available.names, 0, 2)
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]
  database_subnets = ["10.0.201.0/24", "10.0.202.0/24"]

  enable_nat_gateway   = true
  single_nat_gateway   = true  # Usar uno solo para ahorrar costos
  enable_dns_hostnames = true
  enable_dns_support   = true

  create_database_subnet_group = true

  # Tags requeridos para EKS
  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }
}

# ============================================
# EKS Cluster - OPTIMIZADO PARA COSTOS
# ============================================

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "notes-app-eks"
  cluster_version = "1.33"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  cluster_endpoint_public_access = true

  # CloudWatch Logs habilitados para monitoreo
  cluster_enabled_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  # Managed Node Group - 2 nodos t3.small (más económico que t3.medium)
  # t3.micro tiene muy poca RAM (1GB) para EKS
  eks_managed_node_groups = {
    notes_app_nodes = {
      name           = "notes-app-nodes"
      instance_types = ["t3.small"]  # 2 vCPU, 2GB RAM - más económico

      min_size     = 2
      max_size     = 2  # Sin auto-scaling para ahorrar
      desired_size = 2

      # Usar Spot instances para ahorrar ~70%
      capacity_type = "SPOT"

      labels = {
        Environment = var.environment
      }
    }
  }

  # Acceso al cluster
  enable_cluster_creator_admin_permissions = true
}

# ============================================
# AWS Load Balancer Controller (para ALB Ingress)
# ============================================

# IAM Policy para el LB Controller
resource "aws_iam_policy" "lb_controller" {
  name        = "AWSLoadBalancerControllerIAMPolicy"
  description = "IAM policy for AWS Load Balancer Controller"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "iam:CreateServiceLinkedRole"
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "iam:AWSServiceName" = "elasticloadbalancing.amazonaws.com"
          }
        }
      },
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeAccountAttributes",
          "ec2:DescribeAddresses",
          "ec2:DescribeAvailabilityZones",
          "ec2:DescribeInternetGateways",
          "ec2:DescribeVpcs",
          "ec2:DescribeVpcPeeringConnections",
          "ec2:DescribeSubnets",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeInstances",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DescribeTags",
          "ec2:GetCoipPoolUsage",
          "ec2:DescribeCoipPools",
          "elasticloadbalancing:DescribeLoadBalancers",
          "elasticloadbalancing:DescribeLoadBalancerAttributes",
          "elasticloadbalancing:DescribeListeners",
          "elasticloadbalancing:DescribeListenerCertificates",
          "elasticloadbalancing:DescribeSSLPolicies",
          "elasticloadbalancing:DescribeRules",
          "elasticloadbalancing:DescribeTargetGroups",
          "elasticloadbalancing:DescribeTargetGroupAttributes",
          "elasticloadbalancing:DescribeTargetHealth",
          "elasticloadbalancing:DescribeTags"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "cognito-idp:DescribeUserPoolClient",
          "acm:ListCertificates",
          "acm:DescribeCertificate",
          "iam:ListServerCertificates",
          "iam:GetServerCertificate",
          "waf-regional:GetWebACL",
          "waf-regional:GetWebACLForResource",
          "waf-regional:AssociateWebACL",
          "waf-regional:DisassociateWebACL",
          "wafv2:GetWebACL",
          "wafv2:GetWebACLForResource",
          "wafv2:AssociateWebACL",
          "wafv2:DisassociateWebACL",
          "shield:GetSubscriptionState",
          "shield:DescribeProtection",
          "shield:CreateProtection",
          "shield:DeleteProtection"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ec2:AuthorizeSecurityGroupIngress",
          "ec2:RevokeSecurityGroupIngress",
          "ec2:CreateSecurityGroup",
          "ec2:CreateTags",
          "ec2:DeleteTags",
          "ec2:DeleteSecurityGroup"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "elasticloadbalancing:CreateLoadBalancer",
          "elasticloadbalancing:CreateTargetGroup"
        ]
        Resource = "*"
        Condition = {
          Null = {
            "aws:RequestTag/elbv2.k8s.aws/cluster" = "false"
          }
        }
      },
      {
        Effect = "Allow"
        Action = [
          "elasticloadbalancing:AddTags",
          "elasticloadbalancing:RemoveTags"
        ]
        Resource = [
          "arn:aws:elasticloadbalancing:*:*:targetgroup/*/*",
          "arn:aws:elasticloadbalancing:*:*:loadbalancer/net/*/*",
          "arn:aws:elasticloadbalancing:*:*:loadbalancer/app/*/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "elasticloadbalancing:ModifyLoadBalancerAttributes",
          "elasticloadbalancing:SetIpAddressType",
          "elasticloadbalancing:SetSecurityGroups",
          "elasticloadbalancing:SetSubnets",
          "elasticloadbalancing:DeleteLoadBalancer",
          "elasticloadbalancing:ModifyTargetGroup",
          "elasticloadbalancing:ModifyTargetGroupAttributes",
          "elasticloadbalancing:DeleteTargetGroup"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "elasticloadbalancing:RegisterTargets",
          "elasticloadbalancing:DeregisterTargets"
        ]
        Resource = "arn:aws:elasticloadbalancing:*:*:targetgroup/*/*"
      },
      {
        Effect = "Allow"
        Action = [
          "elasticloadbalancing:SetWebAcl",
          "elasticloadbalancing:ModifyListener",
          "elasticloadbalancing:AddListenerCertificates",
          "elasticloadbalancing:RemoveListenerCertificates",
          "elasticloadbalancing:ModifyRule",
          "elasticloadbalancing:CreateListener",
          "elasticloadbalancing:DeleteListener",
          "elasticloadbalancing:CreateRule",
          "elasticloadbalancing:DeleteRule"
        ]
        Resource = "*"
      }
    ]
  })
}

# IRSA (IAM Role for Service Account) para LB Controller
module "lb_controller_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.0"

  role_name = "aws-load-balancer-controller"

  attach_load_balancer_controller_policy = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-load-balancer-controller"]
    }
  }
}

# ============================================
# AWS Load Balancer Controller (Helm)
# ============================================

resource "helm_release" "aws_load_balancer_controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  version    = "1.6.2"

  set {
    name  = "clusterName"
    value = module.eks.cluster_name
  }

  set {
    name  = "serviceAccount.create"
    value = "true"
  }

  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.lb_controller_irsa.iam_role_arn
  }

  set {
    name  = "region"
    value = var.aws_region
  }

  set {
    name  = "vpcId"
    value = module.vpc.vpc_id
  }

  depends_on = [
    module.eks,
    module.lb_controller_irsa
  ]
}

# ============================================
# RDS MySQL - FREE TIER OPTIMIZADO
# ============================================

resource "aws_security_group" "rds" {
  name        = "notes-app-rds-sg"
  description = "Security group for RDS MySQL"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "MySQL from EKS nodes"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = module.vpc.private_subnets_cidr_blocks
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

module "rds" {
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 6.0"

  identifier = "notes-app-db"

  engine               = "mysql"
  engine_version       = "8.0"
  family               = "mysql8.0"
  major_engine_version = "8.0"
  instance_class       = "db.t3.micro"  # FREE TIER: 750 hrs/mes primer año

  allocated_storage     = 20  # FREE TIER: hasta 20GB incluido
  max_allocated_storage = 20  # Sin auto-scaling de storage

  db_name  = "notes_db"
  username = var.db_username
  password = var.db_password
  port     = 3306

  # Optimizaciones de costo
  multi_az                        = false  # Single AZ (ahorra ~50%)
  db_subnet_group_name            = module.vpc.database_subnet_group_name
  vpc_security_group_ids          = [aws_security_group.rds.id]
  publicly_accessible             = false
  storage_encrypted               = false  # FREE TIER no incluye encriptación
  performance_insights_enabled    = false  # Costo adicional
  enabled_cloudwatch_logs_exports = []     # Sin logs a CloudWatch
  
  # Backup mínimo
  backup_retention_period = 1  # Mínimo: 1 día
  backup_window          = "03:00-04:00"
  maintenance_window     = "Mon:04:00-Mon:05:00"
  
  # Sin snapshot final (desarrollo)
  skip_final_snapshot = true
  deletion_protection = false

  # Deshabilitar manage_master_user_password para evitar Secrets Manager
  manage_master_user_password = false

  parameters = [
    {
      name  = "character_set_server"
      value = "utf8mb4"
    },
    {
      name  = "collation_server"
      value = "utf8mb4_unicode_ci"
    }
  ]
}

# ============================================
# Outputs
# ============================================

output "aws_region" {
  description = "AWS Region"
  value       = var.aws_region
}

output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "eks_cluster_name" {
  description = "EKS Cluster name"
  value       = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  description = "EKS Cluster endpoint"
  value       = module.eks.cluster_endpoint
}

output "rds_endpoint" {
  description = "RDS endpoint"
  value       = module.rds.db_instance_endpoint
}

output "rds_database_name" {
  description = "RDS database name"
  value       = module.rds.db_instance_name
}

output "alb_controller_status" {
  description = "ALB Controller installation status"
  value       = "AWS Load Balancer Controller installed via Helm"
}

output "configure_kubectl" {
  description = "Command to configure kubectl"
  value       = "aws eks update-kubeconfig --name ${module.eks.cluster_name} --region ${var.aws_region}"
}

output "dockerhub_images" {
  description = "Docker Hub images to use"
  value = {
    backend  = "${var.dockerhub_username}/notes-app-backend:latest"
    frontend = "${var.dockerhub_username}/notes-app-frontend:latest"
  }
}

output "estimated_monthly_cost" {
  description = "Estimated monthly cost (USD)"
  value = <<-EOT
    
    ╔══════════════════════════════════════════════════════════════╗
    ║           COSTOS ESTIMADOS MENSUALES (us-east-1)             ║
    ╠══════════════════════════════════════════════════════════════╣
    ║ EKS Control Plane          │  $72.00                         ║
    ║ EC2 Spot (2x t3.small)     │  ~$8.00  (vs $30 on-demand)    ║
    ║ RDS db.t3.micro            │  $0.00*  (Free Tier 1er año)   ║
    ║ NAT Gateway                │  ~$32.00                        ║
    ║ ALB                        │  ~$16.00                        ║
    ║ EBS Storage                │  ~$2.00                         ║
    ╠══════════════════════════════════════════════════════════════╣
    ║ TOTAL ESTIMADO             │  ~$130/mes                      ║
    ║ (vs ~$200 config anterior) │  AHORRO: ~35%                  ║
    ╚══════════════════════════════════════════════════════════════╝
    
    * RDS Free Tier: 750 hrs/mes db.t3.micro + 20GB storage (12 meses)
    
    💡 TIPS para reducir más:
    - Destruir infra cuando no uses: ./scripts/03-destroy.sh
    - Usar solo en horario de práctica
  EOT
}
