terraform {
  required_version = ">= 1.6"
  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }

    multipass = {
      source  = "todoroff/multipass"
      version = "~> 1.4"
    }

    external = {
      source  = "hashicorp/external"
      version = "~> 2.3"
    }
  }
}

