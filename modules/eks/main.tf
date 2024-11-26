resource "aws_eks_cluster" "this" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_cluster.arn
  vpc_config {
    subnet_ids = var.private_subnet_ids
  }
  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_AmazonEKSClusterPolicy, //ensures that the IAM role policy is attached before creating the cluster
  ]
}

resource "aws_eks_node_group" "this" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "${var.cluster_name}-node-group"
  node_role_arn   = aws_iam_role.eks_nodes.arn
  subnet_ids      = var.private_subnet_ids
  scaling_config {
    desired_size = 2
    max_size     = 2
    min_size     = 2
  }
  instance_types = ["t3.medium"]
  depends_on = [
    aws_iam_role_policy_attachment.eks_nodes_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.eks_nodes_AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.eks_nodes_AmazonEC2ContainerRegistryReadOnly,
  ]
}

resource "aws_iam_role" "eks_cluster" {          // this policy attached to the EKS for allowing the control planw to 
  name = "${var.cluster_name}-eks-cluster-role" //interact with other services in AWS
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_cluster_AmazonEKSClusterPolicy" { // this policy attached to the worker nodes for allowing the worker nodes to 
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"                  //interact with EKS for join to the cluster, report the health etc...
  role       = aws_iam_role.eks_cluster.name
}

resource "aws_iam_role" "eks_nodes" {
  name = "${var.cluster_name}-eks-nodes-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_nodes_AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy" // It allows the EC2 instances (nodes) to interact with the EKS control plane
  role       = aws_iam_role.eks_nodes.name
}

resource "aws_iam_role_policy_attachment" "eks_nodes_AmazonEKS_CNI_Policy" { 
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy" // Container Network Interface (CNI) that allows the pods
  role       = aws_iam_role.eks_nodes.name                    // to have direct access to the VPC network
}

resource "aws_iam_role_policy_attachment" "eks_nodes_AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly" // that allows the worker node to pull images
  role       = aws_iam_role.eks_nodes.name                                  // from the ECR
}


data "aws_eks_cluster_auth" "this" {
  name = aws_eks_cluster.this.name //retrieves the authentication token required to connect to the EKS cluster
}
