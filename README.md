# Nops Agent Helm Chart

This add-on configures [nops-k8s-agent](https://github.com/nops-io/nops-k8s-agent). Worker contains database to keep users entries and pulls metadata from their accounts on a scheduled basis.

## Secret
Create a Secret for nops-k8s-agent with following values in it:
1. `nops_api_key`  
2. `aws_account_id`

To learn how to create the `nops_api_key`, see [nOps API Key](https://docs.nops.io/en/articles/5955764-getting-started-with-the-nops-developer-api).

The `aws_account_id` refers to your AWS account number that is configured within nOps.

> **Note:** Currently the agent does not support signature verification.

The following is an example of Secret Manifest Reference:

    apiVersion: v1
    kind: Secret
    type: Opaque
    metadata:
      name: nops-k8s-agent
      namespace: <same as nops-k8s-agent installation>
    data:
      nops_api_key: YWRtaW4=
      aws_account_id: MWYyZDFlMmU2N2Rm


<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.72 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | >= 2.4.1 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.10 |

## Deploy Prometheus

You can use your own Prometheus instance or you can launch your nops-k8s-agent namespace directly:

    helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
    helm install prometheus prometheus-community/kube-prometheus-stack

To use your own Prometheus instance, use the deployed prometheus url in `app_prometheus_server_endpoint` variable.


## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 3.72 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_helm_addon"></a> [helm\_addon](#module\_helm\_addon) | ../helm-addon | n/a |

## Resources

| Name | Type |
|------|------|
| [kubernetes_secret.nops_secrets](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secrets) | resource |
| [aws_eks_cluster.eks](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_addon_context"></a> [addon\_context](#input\_addon\_context) | Input configuration for the addon | <pre>object({<br>    aws_caller_identity_account_id = string<br>    aws_caller_identity_arn        = string<br>    aws_eks_cluster_endpoint       = string<br>    aws_partition_id               = string<br>    aws_region_name                = string<br>    eks_cluster_id                 = string<br>    eks_oidc_issuer_url            = string<br>    eks_oidc_provider_arn          = string<br>    tags                           = map(string)<br>    irsa_iam_role_path             = string<br>    irsa_iam_permissions_boundary  = string<br>  })</pre> | n/a | yes |
| <a name="input_helm_config"></a> [helm\_config](#input\_helm\_config) | Helm Config for nops. | `any` | `{}` | no |
| <a name="input_manage_via_gitops"></a> [manage\_via\_gitops](#input\_manage\_via\_gitops) | Determines if the add-on should be managed via GitOps. | `bool` | `false` | no |
| <a name="input_app_nops_k8s_collector_api_key"></a> [app\_nops\_k8s\_collector\_api\_key](#input\app\_nops\_k8s\_collector\_api\_key) | API Key of nOps| `string` | `""` | yes |
| <a name="input_app_prometheus_server_endpoint"></a> [app\_prometheus\_server\_endpoint](#input\app\_prometheus\_server\_endpoint) | Prometheus server endpoint| `string` | `""` | yes |
| <a name="input_app_nops_k8s_agent_clusterid"></a> [app\_nops\_k8s\_agent\_clusterid](#input\app\_nops\_k8s\_agent\_clusterid) | NOPS agent cluster id| `any` | `{}` | yes |
| <a name="input_app_nops_k8s_collector_skip_ssl"></a> [app\_nops\_k8s\_k8s\_collector\_skip\_ssl](#input\app\_nops\_k8s\_collector\_skip\_ssl) | NOPS collector aws account number| `any` | `{}` | yes |
| <a name="input_app_nops_k8s_agent_prom_token"></a> [app\_nops\_k8s\_k8s\_agent\_prom\_token](#input\app\_nops\_k8s\_agent\_prom\_token) | App nops agent prometheus token| `any` | `{}` | yes |


## Outputs
| Name | Description |
|------|------|
| <a name="output_argocd_gitops_config"></a> [argocd\_gitops\_config](#output\_argocd\_gitops\_config) | Configuration used for managing the add-on with ArgoCD |
<!--- END_TF_DOCS --->
