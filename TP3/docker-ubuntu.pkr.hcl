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

  # Provisioner 1 : 
  provisioner "file" {
    destination = "/tmp/example.txt"
    content     = var.file_content
  }

  # Provisioner 2 
  provisioner "file" {
    source      = "welcome.txt"
    destination = "/home/welcome.txt"
  }

  post-processor "manifest" {
    output = "manifest.json"
  }
}
