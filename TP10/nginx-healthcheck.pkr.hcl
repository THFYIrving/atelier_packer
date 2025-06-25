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

source "amazon-ebs" "nginx" {
  ami_name      = "nginx-healthcheck-${local.timestamp}"
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
  name    = "nginx-healthcheck"
  sources = ["source.amazon-ebs.nginx"]

  provisioner "shell" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y nginx curl",
      "echo '<h1>Bienvenue sur mon serveur NGINX - Healthcheck</h1>' | sudo tee /var/www/html/index.html",
      "sudo systemctl enable nginx",
      "sudo systemctl start nginx"
    ]
  }

  provisioner "shell" {
    inline = [
      "echo '[TEST] Vérification de Nginx...'",

      "sudo nginx -t || (echo '[❌ FAIL] Erreur config nginx' && exit 1)",
      "sudo systemctl is-active nginx | grep active || (echo '[❌ FAIL] Nginx inactif' && exit 1)",
      "curl -s http://localhost | grep 'Bienvenue' || (echo '[❌ FAIL] Page HTML absente' && exit 1)",

      "echo '[OK] Healthcheck Nginx terminé avec succès'"
    ]
  }
}
