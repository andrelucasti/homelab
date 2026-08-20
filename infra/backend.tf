terraform {
  backend "oci" {
    # Required
    bucket            = "homelab-terraform-andre"
    namespace         = "axzzzpaxgpvp"

    config_file_profile = "HOMELAB"

    # Nome do objeto do state dentro do bucket
    key = "homelab/terraform.tfstate"
  }
}
