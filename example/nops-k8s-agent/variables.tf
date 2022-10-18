variable "cluster_name" {
  type        = string
  description = "EKS cluster name."
  default = "nops-addon-agent
}
variable "name_prefix" {
  type        = string
  description = "Prefix to be used on each infrastructure object Name created in AWS."
  default = "poc-addon"
}
variable "main_network_block" {
  type        = string
  description = "Base CIDR block to be used in our VPC."
  default = "10.0.0.0/24"
}
variable "eks_managed_node_groups" {
  type        = map(any)
  description = "Map of EKS managed node group definitions to create"
  default ={
  "nops-addon-poc-eks-x86" = {
    ami_type     = "AL2_x86_64"
    min_size     = 1
    max_size     = 16
    desired_size = 1
    instance_types = [
      "t3.medium"
    ]
    capacity_type = "SPOT"
    network_interfaces = [{
      delete_on_termination       = true
      associate_public_ip_address = true
    }]
  }
}

variable "autoscaling_average_cpu" {
  type        = number
  description = "Average CPU threshold to autoscale EKS EC2 instances."
  default = 30
}

