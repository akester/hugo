variable "version" {
  type    = string
  default = "latest"
}

source "docker" "debian" {
  commit  = true
  image   = "debian:12"
}

build {
  sources = ["source.docker.debian"]

  provisioner "shell" {
    environment_vars = [
      "DEBIAN_FRONTEND=noninteractive",
      "DEBIAN_PRIORITY=critical"
    ]
    inline           = [
      "set -e",
      "set -x",
      "apt-get update",
      "apt-get -y dist-upgrade",
    ]
    inline_shebang   = "/bin/bash -e"
  }


  provisioner "shell" {
    environment_vars = [
      "DEBIAN_FRONTEND=noninteractive",
      "DEBIAN_PRIORITY=critical"
    ]
    inline           = [
      "set -e",
      "set -x",
      "apt-get -y install wget",
      "wget -O /tmp/hugo.deb https://github.com/gohugoio/hugo/releases/download/v0.136.2/hugo_extended_0.136.2_linux-amd64.deb",
      "dpkg -i /tmp/hugo.deb",
    ]
    inline_shebang   = "/bin/bash -e"
  }

  provisioner "shell" {
    environment_vars = [
      "DEBIAN_FRONTEND=noninteractive",
      "DEBIAN_PRIORITY=critical"
    ]
    inline           = [
      "set -e",
      "set -x",
      "rm /etc/apt/apt.conf.d/01proxy",
      "apt update",
      "apt autoremove",
      "apt clean",
    ]
    inline_shebang   = "/bin/bash -e"
  }

  post-processor "docker-tag" {
    repository = "registry.gatewayks.net/hugo/hugo"
    tags       = [
      "${var.version}"
    ]
  }
}

packer {
  required_plugins {
    docker = {
      version = ">= 0.0.7"
      source = "github.com/hashicorp/docker"
    }
  }
}
