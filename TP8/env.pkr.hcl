packer {
  required_plugins {
    amazon = {
      version = ">= 1.2.8"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")
}

#variable "environment" {
#  type    = string
#  default = "dev"
#  validation {
#    condition     = contains(["dev", "staging", "production"], var.environment)
#    error_message = "L'environnement doit être 'dev', 'staging' ou 'production'."
#  }
#}

#variable "git_version" {
#  type    = string
#  default = "1:2.34.1"
#  validation {
#    condition     = can(regex("^[0-9]+:[0-9]+\\.[0-9]+\\.[0-9]+$", var.git_version))
#   error_message = "Format attendu : '1:2.34.1' (avec epoch facultatif)."
# }
#}

source "amazon-ebs" "ubuntu" {
  ami_name      = "env-${var.environment}-${local.timestamp}"
  instance_type = "t2.micro"
  region        = "us-east-1"
  source_ami_filter {
    filters = {
      name                = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }
  ssh_username = "ubuntu"
}

build {
  name    = var.environment
  sources = ["source.amazon-ebs.ubuntu"]

  # Git installé uniquement en dev ou staging
  provisioner "shell" {
    only = ["dev", "staging"]
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y git=${var.git_version}"
    ]
  }

  # Bloc toujours exécuté
  provisioner "shell" {
    inline = [
      "which git || echo 'Git non installé'",
      "git --version || echo 'Git non détecté'"
    ]
  }
}
