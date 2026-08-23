variable "tailscale_authkey" {
  description = "Auth key do Tailscale (tskey-auth-...). Passar via TF_VAR_tailscale_authkey ou secrets.auto.tfvars (nunca commitado)."
  type        = string
  sensitive   = true
}

variable "kubeconfig_path" {
  description = "Nome do arquivo de kubeconfig gerado, relativo ao modulo."
  type        = string
  default     = "kubeconfig.yaml"
}
