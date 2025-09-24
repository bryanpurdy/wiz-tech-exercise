# Fetch cluster details directly
data "aws_eks_cluster" "this" {
  name = module.eks.cluster_name
}

# Mongo EC2 Private IP
output "mongo_private_ip_a" {
  value = aws_instance.mongo.private_ip
}

# S3 Bucket Name
output "s3_bucket_name" {
  value = aws_s3_bucket.wiz_bucket.bucket
}

# EKS Cluster Name
output "eks_cluster_name" {
  value = module.eks.cluster_name
}

# EKS Cluster Endpoint
output "eks_cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

# EKS Cluster Endpoint Public Access
output "eks_cluster_endpoint_public_access" {
  value = data.aws_eks_cluster.this.vpc_config[0].endpoint_public_access
}

# EKS Cluster Endpoint Private Access
output "eks_cluster_endpoint_private_access" {
  value = data.aws_eks_cluster.this.vpc_config[0].endpoint_private_access
}

# Public cidr
output "eks_cluster_public_access_cidrs" {
  value = data.aws_eks_cluster.this.vpc_config[0].public_access_cidrs
}

# Mongo Instance ID
output "mongo_instance_id_a" {
  value = aws_instance.mongo.id
}

# Node Group Role ARN
output "eks_node_group_role_arn" {
  value = module.eks.eks_managed_node_groups["default"].iam_role_arn
}
