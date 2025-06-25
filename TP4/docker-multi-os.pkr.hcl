packer {
  required_plugins {
    docker = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/docker"
    }
  }
}

# ---------- SOURCES ----------

source "docker" "ubuntu" {
  image  = "ubuntu:22.04"
  commit = true
}

source "docker" "alpine" {
  image  = "alpine:3.18"
  commit = true
}

# BUILD UBUNTU

build {
  name    = "ubuntu-build"
  sources = ["source.docker.ubuntu"]

  provisioner "shell" {
    inline = [
      "apt update",
      "apt install -y curl wget",
      "uname -a > /system-info.txt",
      "cat /etc/os-release >> /system-info.txt"
    ]
  }

  provisioner "file" {
    source      = "show-info.sh"
    destination = "/usr/local/bin/show-info.sh"
  }

  post-processor "docker-tag" {
    repository = "multi-os-ubuntu"
    tag = ["latest"]
  }

  post-processor "manifest" {
    output = "ubuntu-manifest.json"
  }
}

# ---------- BUILD ALPINE ----------

build {
  name    = "alpine-build"
  sources = ["source.docker.alpine"]

  provisioner "shell" {
    inline = [
      "apk update",
      "apk add curl wget",
      "uname -a > /system-info.txt",
      "cat /etc/os-release >> /system-info.txt"
    ]
  }

  provisioner "file" {
    source      = "show-info.sh"
    destination = "/usr/local/bin/show-info.sh"
  }

  post-processor "docker-tag" {
    repository = "multi-os-alpine"
    tag = ["latest"]
  }

  post-processor "manifest" {
    output = "alpine-manifest.json"
  }
}
