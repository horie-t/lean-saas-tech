# EKS Cluster with Fargate

This Terraform configuration creates an Amazon EKS (Elastic Kubernetes Service) cluster using AWS Fargate in the us-west-2 region.

## Architecture

The infrastructure includes:

- A VPC with public and private subnets across three availability zones
- An EKS cluster running on Fargate (serverless)
- IAM roles and policies for the EKS cluster and Fargate profiles
- Security groups for the EKS cluster

## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) (version >= 1.0.0)
- [AWS CLI](https://aws.amazon.com/cli/) configured with appropriate credentials
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/) for interacting with the Kubernetes cluster

## Usage

1. Initialize the Terraform configuration:

```bash
terraform init
```

2. Review the planned changes:

```bash
terraform plan
```

3. Apply the configuration:

```bash
terraform apply
```

4. After the cluster is created, configure kubectl to connect to your cluster:

```bash
aws eks update-kubeconfig --region us-west-2 --name lean-saas-eks-cluster
```

5. Verify the connection:

```bash
kubectl get nodes
```

## Variables

| Name | Description | Default |
|------|-------------|---------|
| cluster_name | Name of the EKS cluster | lean-saas-eks-cluster |
| cluster_version | Kubernetes version to use for the EKS cluster | 1.24 |
| region | AWS region to deploy the EKS cluster | us-west-2 |

For a complete list of variables, see the `variables.tf` file.

## Outputs

| Name | Description |
|------|-------------|
| cluster_endpoint | Endpoint for EKS control plane |
| cluster_id | EKS cluster ID |
| configure_kubectl | Command to configure kubectl |

For a complete list of outputs, see the `outputs.tf` file.

## Cleanup

To destroy the created resources:

```bash
terraform destroy
```

## Notes

- This configuration uses Fargate profiles for running pods, which means there are no EC2 instances to manage.
- The cluster is configured with the minimum necessary resources for a development environment.
- For production use, consider additional security measures and resource configurations.