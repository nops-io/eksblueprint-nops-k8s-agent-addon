# nOps k8s Agent

This add-on configures [nops-k8s-agent](https://github.com/nops-io/nops-k8s-agent). Worker contains database to keep users entries and pulls metadata from their accounts on a scheduled basis.

This examples deployment show the usage, steps, and the deployment process of the agent. 

## Usage

[nOps Agent](https://github.com/aws-ia/terraform-aws-eks-blueprints/tree/main/modules/kubernetes-addons/nops-k8s-agent) can be deployed by enabling the add-on by setting the following confifugration:

    enable_nops_k8s_agent = true

The next step is to add your custom values for the environment variables in the `values.yaml` file.

You must pass values for of the following environment variable in the `values.yaml` file. 

    default_helm_values = [templatefile("${path.module}/values.yaml", {
        operating_system = "linux"
        region = var.addon_context.aws_region_name,
        app_nops_k8s_collector_api_key = var.app_nops_k8s_collector_api_key
        app_prometheus_server_endpoint = var.app_prometheus_server_endpoint
        app_nops_k8s_agent_clusterid  = var.app_nops_k8s_agent_clusterid
        app_nops_k8s_collector_skip_ssl = var.app_nops_k8s_collector_skip_ssl
        app_nops_k8s_agent_prom_token = var.app_nops_k8s_agent_prom_token
    })]

Required variables defination:

* `APP_PROMETHEUS_SERVER_ENDPOINT` - Depends on your Prometheus stack installation (different for every person and every cluster).
* `APP_NOPS_K8S_AGENT_CLUSTER_ID` - needs to match with your cluster ID.
* `APP_NOPS_K8S_COLLECTOR_API_KEY` - See, nOps Developer API to learn how to get your API key. [nOps API Key](https://docs.nops.io/en/articles/5955764-getting-started-with-the-nops-developer-api)

## Deployment

To start the deployment, run the following commands:

    cd examples/nops-k8s-agent
    terraform init

Run Terraform plan to verify the resources created by this execution.

    export AWS_REGION=<enter-your-region>   # Select your own region
    terraform plan
    terraform apply

Enter `yes` to apply.

The environment variables if changed in the directory will become the new default. You can override these values during deployment of the agent via helm repo.

Once deployed, you can see nOps agent pod in the `nops-k8s-agent` namespace.

```sh
$ kubectl get cronjob -n nops-k8s-agent

NAME                                                          READY   UP-TO-DATE   AVAILABLE   AGE
nops-k8s-agent-high                                           1/1     1            1           20m
```

### GitOps Configuration

The following properties are made available for use when managing the add-on via GitOps

```
nops_k8s_agent = {
  enable = true
}
```
