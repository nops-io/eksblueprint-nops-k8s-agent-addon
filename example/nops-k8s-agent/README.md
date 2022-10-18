# Nops agent with EKS

This example deploys an EKS Cluster running the Nops k8s agent into a new VPC.

- Creates a new sample VPC, 3 Private Subnets and 3 Public Subnets
- Creates Internet gateway for Public Subnets and NAT Gateway for Private Subnets
- Creates EKS Cluster Control plane with public endpoint (for demo reasons only) with one managed node group
- Deploys Prometheus

This will install the Kubernetes Operator for Apache Spark into the namespace spark-operator.
The operator by default watches and handles SparkApplications in all namespaces.
If you would like to limit the operator to watch and handle SparkApplications in a single namespace, e.g., default instead, add the following option to the helm install command:

## Prerequisites

Ensure that you have installed the following tools on your machine.

1. [aws cli](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)
2. [kubectl](https://Kubernetes.io/docs/tasks/tools/)
3. [terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)

## Step 1: Deploy EKS Cluster with Spark-K8s-Operator feature

Clone the repository

```
git clone https://github.com/aws-ia/terraform-aws-eks-blueprints.git
```

Apply all the value in the variable defined 

```### Enable nops agent and variables values######################
  enable_nops_k8s_agent = true

  app_nops_k8s_collector_api_key = "xxxxxxxxxxxxxxxxxxxxx" #Api key of nops account 
  app_prometheus_server_endpoint = "http://prometheus-operator-kube-p-prometheus.nops-k8s-agent.svc.cluster.local:9090"
  app_nops_k8s_agent_clusterid  =  module.eks_blueprints.eks_cluster_id
  app_nops_k8s_collector_skip_ssl = ""
  app_nops_k8s_agent_prom_token = ""
```
Navigate into one of the example directories and run `terraform init`

```
cd examples/nops-k8s-agent
terraform init
```

Run Terraform plan to verify the resources created by this execution.

```
export AWS_REGION=<enter-your-region>   # Select your own region
terraform plan
```

**Deploy the pattern**

```sh
terraform apply
```

Enter `yes` to apply.

## Execute Sample Spark Job on EKS Cluster with Spark-k8s-operator

```sh
  cd examples/analytics/spark-k8s-operator/spark-samples
  kubectl apply -f pyspark-pi-job.yaml
```

- Verify the Spark job status

```sh
  kubectl get sparkapplications -n spark-team-a

  kubectl describe sparkapplication pyspark-pi -n spark-team-a
```

## Cleanup

To clean up your environment, destroy the Terraform modules in reverse order.

Destroy the Kubernetes Add-ons, EKS cluster with Node groups and VPC

```sh
terraform destroy -target="module.eks_blueprints_kubernetes_addons" -auto-approve
terraform destroy -target="module.eks_blueprints" -auto-approve
terraform destroy -target="module.vpc" -auto-approve
```

Finally, destroy any additional resources that are not in the above modules

```sh
terraform destroy -auto-approve
```
