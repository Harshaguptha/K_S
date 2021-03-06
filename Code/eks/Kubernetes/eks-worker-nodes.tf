#
# EKS Worker Nodes Resources
#  * IAM role allowing Kubernetes actions to access other AWS services
#  * EKS Node Group to launch worker nodes
#

resource "aws_iam_role" "setup_step-node" {
  name = "terraform-eks-setup_step-node"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "setup_step-node-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.setup_step-node.name
}

resource "aws_iam_role_policy_attachment" "setup_step-node-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.setup_step-node.name
}

resource "aws_iam_role_policy_attachment" "setup_step-node-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.setup_step-node.name
}

resource "aws_eks_node_group" "setup_step" {
  cluster_name    = aws_eks_cluster.setup_step.name
  node_group_name = "setup_step"
  node_role_arn   = aws_iam_role.setup_step-node.arn
  subnet_ids      = aws_subnet.setup_step[*].id
  instance_types  = var.instance_types
  
  scaling_config {
    desired_size = var.desired_size
    max_size     = var.max_size
    min_size     = var.min_size
  }

  depends_on = [
    aws_iam_role_policy_attachment.setup_step-node-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.setup_step-node-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.setup_step-node-AmazonEC2ContainerRegistryReadOnly,
  ]
}
