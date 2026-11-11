terraform {
  required_version = ">= 1.10.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.0, < 7.0"
    }
    local = {
      source  = "hashicorp/local"
      version = ">= 2.5, < 3.0"
    }
  }

  # Bootstrap state stays local but is encrypted with a passphrase (OpenTofu native).
  # Set it with: export TF_VAR_state_passphrase='...'
  encryption {
    key_provider "pbkdf2" "local" {
      passphrase = var.state_passphrase
    }

    method "aes_gcm" "local" {
      keys = key_provider.pbkdf2.local
    }

    state {
      method   = method.aes_gcm.local
      enforced = true
    }

    plan {
      method   = method.aes_gcm.local
      enforced = true
    }
  }
}
