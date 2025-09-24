module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.0.0"

  cluster_name    = var.cluster_name
  cluster_version = "1.29"
  subnet_ids      = module.vpc.private_subnets
  vpc_id          = module.vpc.vpc_id

  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true

  eks_managed_node_groups = {
    default = {
      desired_capacity = 2
      max_capacity     = 3
      min_capacity     = 1
      instance_types   = ["t3.medium"]

      # Ensures nodes can pull images from ECR
      iam_role_additional_policies = {
        ecr_pull = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPullOnly"
      }
    }
  }

  # Keep your access entry so your IAM user can auth
  access_entries = {
    "odl_user" = {
      principal_arn = "arn:aws:iam::864899857894:user/odl_user_1887923"

      policy_associations = {
        "cluster-admin" = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

          access_scope = {
            type       = "cluster"
            namespaces = []
          }
        }
      }
    }
  }
}
