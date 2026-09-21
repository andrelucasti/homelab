# Multipass k3s provisioner

Terraform module that provisions a local k3s cluster on Multipass and connects each node to a Tailscale tailnet. It generates the k3s join token, creates one server and two worker VMs, then writes a Tailscale-reachable kubeconfig to disk.

> [!WARNING]
> This module is under active development. Read [Current limitations](#current-limitations) and inspect the Terraform plan before applying it to an existing cluster.

## Architecture

```mermaid
flowchart LR
    Operator[Operator or CI] --> Terraform[Terraform]
    Terraform --> Token[random_password<br/>k3s join token]
    Terraform --> Master[Multipass VM<br/>k3s server]
    Terraform --> Workers[Multipass VMs<br/>k3s agents]
    Token --> Master
    Token --> Workers
    Master <-->|Multipass private network<br/>TCP 6443| Workers
    Master --> Tailnet[Tailscale tailnet]
    Workers --> Tailnet
    Terraform -->|multipass exec| Config[kubeconfig.yaml<br/>mode 0600]
    Config -->|Tailscale API address| Master
```

## What the module creates

- A 48-character random k3s cluster token.
- One Ubuntu 24.04 Multipass VM running the k3s server.
- Two Ubuntu 24.04 Multipass VMs running k3s agents.
- Tailscale on every VM.
- A local kubeconfig whose API endpoint uses the server's Tailscale IPv4 address.

## Requirements

| Dependency | Requirement |
|---|---|
| Terraform | `>= 1.6` |
| Multipass | Installed, running, and available in `PATH` |
| Host tools | `bash` and `jq` |
| Network | Access to `tailscale.com` and `get.k3s.io` |
| Tailscale | A pre-authorized auth key suitable for all requested nodes |

The auth key should be ephemeral and reusable when more than one node is created. Do not commit it to the repository.

## Usage

```hcl
variable "tailscale_authkey" {
  description = "Ephemeral, reusable Tailscale auth key"
  type        = string
  sensitive   = true
}

module "homelab_cluster" {
  source = "./modules/provisioner"

  name              = "homelab"
  cpus              = "2"
  memory            = "4G"
  disk              = "20G"
  workers           = 2
  tailscale_authkey = var.tailscale_authkey
  kubeconfig_path   = "kubeconfig.yaml"
}
```

Pass the secret through the environment:

```bash
export TF_VAR_tailscale_authkey='tskey-auth-REDACTED'
terraform init
terraform plan
terraform apply
```

The generated kubeconfig is written relative to this module directory and must remain excluded from Git.

## Inputs

| Name | Type | Default | Sensitive | Description |
|---|---|---:|:---:|---|
| `name` | `string` | required | yes | Cluster name used in the server VM name. |
| `cpus` | `string` | required | yes | Number of CPUs assigned to the server VM. |
| `memory` | `string` | required | yes | Server memory accepted by Multipass, for example `4G`. |
| `disk` | `string` | required | yes | Server disk size accepted by Multipass, for example `20G`. |
| `workers` | `number` | `1` | no | Intended worker count. See [Current limitations](#current-limitations). |
| `tailscale_authkey` | `string` | `""` | yes | Tailscale auth key used during cloud-init. |
| `kubeconfig_path` | `string` | `kubeconfig.yaml` | no | Kubeconfig filename relative to the module directory. |

## Outputs

| Name | Description |
|---|---|
| `master_ip` | First Multipass IPv4 address reported for the k3s server VM. |

## Provisioning flow

1. Terraform creates the k3s join token.
2. Multipass starts the server VM and waits for cloud-init.
3. Cloud-init installs Tailscale, joins the tailnet, and installs k3s with the Tailscale address in the API server certificate.
4. Multipass starts the worker VMs after the server is ready.
5. Each worker joins k3s through the server's Multipass IPv4 address.
6. Terraform reads `/etc/rancher/k3s/k3s.yaml` from the server, replaces the loopback endpoint with its Tailscale IPv4 address, and writes the result with `0600` permissions.

## Operations

```bash
terraform fmt -recursive
terraform validate
terraform plan
terraform apply
```

Verify the cluster:

```bash
export KUBECONFIG="infra/modules/provisioner/kubeconfig.yaml"
kubectl get nodes -o wide
```

Destroy only this module after reviewing the plan:

```bash
terraform plan -destroy -target=module.homelab_cluster
terraform destroy -target=module.homelab_cluster
```

## Migrating existing Terraform state

Moving existing root resources into this module changes their Terraform addresses. Without migration, Terraform can plan to destroy the existing cluster and create a new one.

Add temporary `moved` blocks in the root configuration before applying:

```hcl
moved {
  from = random_password.k3s_token
  to   = module.homelab_cluster.random_password.k3s_token
}

moved {
  from = multipass_instance.k8s-master
  to   = module.homelab_cluster.multipass_instance.k8s-master
}

moved {
  from = multipass_instance.k8s-worker
  to   = module.homelab_cluster.multipass_instance.k8s-worker
}

moved {
  from = data.external.kubeconfig
  to   = module.homelab_cluster.data.external.kubeconfig
}

moved {
  from = local_sensitive_file.kubeconfig
  to   = module.homelab_cluster.local_sensitive_file.kubeconfig
}
```

Run `terraform plan` and confirm that no existing VM or token is unexpectedly replaced. Resources outside this module, including Helm releases, must remain declared elsewhere or Terraform will plan to destroy them.

## Security notes

- The Tailscale auth key, k3s token, rendered cloud-init, and kubeconfig can be present in Terraform state. Protect the state backend with encryption and least-privilege access.
- Use short-lived, tagged, pre-authorized Tailscale keys and rotate them regularly.
- The generated kubeconfig contains cluster-admin credentials and is written with `0600` permissions.
- Keep `.terraform/`, `*.tfstate`, `*.tfvars`, and generated kubeconfig files out of Git.
- Review downloaded installation scripts before production use; the current bootstrap downloads and executes unpinned scripts from the internet.

## Current limitations
- `tailscale_authkey` defaults to an empty value instead of failing validation early.
- Kubernetes and Helm provider configuration is coupled to the provisioning module even though the module does not create Kubernetes or Helm resources.
- The Tailscale and k3s installation versions are not pinned, so identical Terraform inputs may produce different clusters over time.
