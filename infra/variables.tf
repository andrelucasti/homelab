variable "tailscale_authkey" {
  description = "Auth key do Tailscale (tskey-auth-...). Passar via TF_VAR_tailscale_authkey ou secrets.auto.tfvars (nunca commitado)."
  type        = string
  sensitive   = true
}
