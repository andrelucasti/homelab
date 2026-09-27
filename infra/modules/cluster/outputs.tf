output "master_ip" {
  value = multipass_instance.k8s-master.ipv4[0]
}
output "kubeconfig_raw" {
  description = "Raw kubeconfig extracted from the K3s server"
  value       = data.external.kubeconfig.result.raw
  sensitive   = true
}