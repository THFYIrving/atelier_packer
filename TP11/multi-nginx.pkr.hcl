packer {
  required_plugins {
    amazon = {
      version = ">= 1.2.8"
      source  = "github.com/hashicorp/amazon"
    }
    docker = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/docker"
    }
  }
}

locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")
}

# Source AMI pour AWS
source "amazon-ebs" "nginx_aws" {
  ami_name      = "nginx-dual-aws-${local.timestamp}"
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

# Source Docker (local)
source "docker" "nginx_docker" {
  image  = "ubuntu:22.04"
  commit = true
}

# Build commun (Docker/AWS)
build {
  name    = "nginx_dual_build"
  sources = ["source.amazon-ebs.nginx_aws", "source.docker.nginx_docker"]

  provisioner "shell" {
    inline = [
      "apt-get update",
      "apt-get install -y nginx curl",
      "echo '<h1>NGINX depuis une image multi-plateforme</h1>' > /var/www/html/index.html",
      "systemctl enable nginx || true",
      "systemctl start nginx || true"
    ]
  }

  provisioner "shell" {
    inline = [
      "nginx -t",
      "curl -s http://localhost | grep NGINX || exit 1"
    ]
  }

  post-processor "docker-tag" {
    repository = "nginx-dual"
    tag        = ["latest"]
  }

  post-processor "docker-save" {
    path = "nginx-dual.tar"
  }
}
