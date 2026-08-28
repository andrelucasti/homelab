variable "tailscale_issuer" {
    description = "Tailscale OIDC issuer"
    type = string
    default = "https://token.actions.githubusercontent.com" 
}

variable "tailscale_subject" {
    description = "Tailscale OIDC subject"
    type = string
}

variable "taiscale_tags" {
    description = "Tailscale OIDC tags"
    type = list(string)
    default = ["tag:ci"]
}

variable "tailscale_oauth_client_id" {
    description = "OAuth client ID used by the Tailscale provider"
    type = string
}

variable "tailscale_oauth_client_secret" {
    description = "OAuth client secret used by the Tailscale provider"
    type = string
    sensitive = true
}

variable "tailscale_tailnet" {
    description = "Tailnet name"
    type = string
    default = "tailf345b0.ts.net"
}
