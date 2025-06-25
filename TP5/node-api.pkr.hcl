packer {
  required_plugins {
    docker = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/docker"
    }
  }
}

source "docker" "node-api" {
  image  = "node:18"
  commit = true
  changes = [
    "CMD [\"npm\",\"start\"]",
    "WORKDIR /app",
    ]
}

build {
  name    = "node-api-build"
  sources = ["source.docker.node-api"]

  provisioner "shell" {
    inline = [
      "apt update && apt install -y git",
      "git clone https://gitlab.com/vm-marvelab/ci-cd.git /app",
      "cd /app && npm install",
    ]
  }

  post-processor "docker-tag" {
    repository = "node-api"
    tag        = ["latest"]
  }
}
