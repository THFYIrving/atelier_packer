packer {
  required_plugins {
    docker = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/docker"
    }
  }
}

source "docker" "ubuntu" {
  image  = var.image_name
  commit = true
}

build {
  sources = ["source.docker.ubuntu"]

  provisioner "file" {
    destination = "/tmp/example.txt"
    content     = var.file_content
  }
}
