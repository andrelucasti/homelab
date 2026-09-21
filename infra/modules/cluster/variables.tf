
variable "cpus" {
    description = "Cpu Size"
    type = string
    sensitive = true  
}

variable "memory" {
    description = "Memory size"
    type = string
    sensitive = true  
}

variable "disk" {
    description = "Disk size"
    type = string
    sensitive = true  
}

variable "workers" {
    description = "Amount of workers node"
    type = number
    default = 1
}

variable "tailscale_authkey" {
  description = "Auth key do Tailscale (tskey-auth-...). Passar via TF_VAR_tailscale_authkey ou secrets.auto.tfvars (nunca commitado)."
  type        = string
  sensitive   = true
  default = ""
}