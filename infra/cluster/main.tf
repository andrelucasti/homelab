module "homelab_cluster" {
  source            = "../modules/cluster"
  cpus              = "2"
  memory            = "4G"
  disk              = "10G"
  workers           = 2
  tailscale_authkey = var.tailscale_authkey
}

resource "local_sensitive_file" "kubeconfig" {
  content              = module.homelab_cluster.kubeconfig_raw
  filename             = abspath("${path.root}/../.generated/kubeconfig.yaml")
  file_permission      = "0600"
  directory_permission = "0700"
}

output "kubeconfig_path" {
  description = "Caminho do kubeconfig exportado automaticamente pelo cluster."
  value       = local_sensitive_file.kubeconfig.filename
}
