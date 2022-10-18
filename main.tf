module "helm_addon" {
  source            = "github.com/aws-ia/terraform-aws-eks-blueprints//modules/kubernetes-addons/helm-addon?ref=v4.1.0"
  manage_via_gitops = var.manage_via_gitops
  set_values        = local.set_values
  helm_config       = local.helm_config
  irsa_config       = local.irsa_config
  addon_context     = var.addon_context
}

resource "aws_iam_policy" "nops-k8s-agent" {
  description = "IAM policy for nops-k8s-agent Pod"
  name        = "${var.addon_context.eks_cluster_id}-nops-k8s-agent"
  path        = var.addon_context.irsa_iam_role_path
  policy      = data.aws_iam_policy_document.this.json
}

resource "kubernetes_secret" "nops_secrets" {
  metadata {
      name = "nops-k8s-agent"
      namespace = "nops-k8s-agent"
   }
  data = {
       nops_api_key = "${var.app_nops_k8s_collector_api_key}"
       aws_account_id = data.aws_caller_identity.current.account_id
      }
  depends_on = [aws_iam_policy.nops-k8s-agent]
  
}
