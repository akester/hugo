variable "version" {
  type    = string
}

variable "hugo_version" {
  type    = string
}

source "docker" "debian-amd64" {
  commit = true
  image  = "debian:13"
  changes = [
    "ENTRYPOINT [\"\"]",
    "WORKDIR [\"/tmp\"]"
  ]
}

source "docker" "debian-arm64" {
  commit = true
  image  = "arm64v8/debian:13"
  changes = [
    "ENTRYPOINT [\"\"]",
    "WORKDIR [\"/tmp\"]"
  ]
}

build {
sources = [
    "source.docker.debian-amd64",
    "source.docker.debian-arm64"
  ]

  provisioner "shell" {
    environment_vars = [
      "DEBIAN_FRONTEND=noninteractive",
      "DEBIAN_PRIORITY=critical"
    ]
    inline = [
      "set -e",
      "set -x",
      "apt-get update",
      "apt-get -y dist-upgrade",
    ]
    inline_shebang = "/bin/bash -e"
  }

  provisioner "shell" {
    environment_vars = [
      "DEBIAN_FRONTEND=noninteractive",
      "DEBIAN_PRIORITY=critical"
    ]
    inline = [
      "set -e",
      "set -x",
      "apt-get -y install wget golang",
  ]
    inline_shebang = "/bin/bash -e"
  }

  # Download the correct exec for our arch
  provisioner "shell" {
    inline = [
      "wget -nv -O /tmp/hugo.tar.gz  https://github.com/gohugoio/hugo/releases/download/v${var.hugo_version}/hugo_extended_${var.hugo_version}_linux-amd64.tar.gz",
    ]
    inline_shebang = "/bin/bash -e"
    only = ["docker.debian-amd64"]

  }
  provisioner "shell" {
    inline = [
      "wget -nv -O /tmp/hugo.tar.gz  https://github.com/gohugoio/hugo/releases/download/v${var.hugo_version}/hugo_extended_${var.hugo_version}_linux-arm64.tar.gz",
    ]
    inline_shebang = "/bin/bash -e"
    only = ["docker.debian-arm64"]
  }

  provisioner "shell" {
    environment_vars = [
      "DEBIAN_FRONTEND=noninteractive",
      "DEBIAN_PRIORITY=critical"
    ]
    inline = [
      "cd /tmp && tar -xzvf hugo.tar.gz",
      "mv /tmp/hugo /usr/bin/hugo",
      "chmod 0755 /usr/bin/hugo",
      "rm /tmp/hugo.tar.gz",
    ]
    inline_shebang = "/bin/bash -e"
  }

  provisioner "shell" {
    environment_vars = [
      "DEBIAN_FRONTEND=noninteractive",
      "DEBIAN_PRIORITY=critical"
    ]
    inline = [
      "set -e",
      "set -x",
      "rm -f /etc/apt/apt.conf.d/01proxy",
      "apt update",
      "apt autoremove",
      "apt clean",
    ]
    inline_shebang = "/bin/bash -e"
  }

  post-processor "docker-tag" {
    repository = "akester/hugo"
    tags = [
      "${source.name}-${var.version}",
    ]
  }
}

packer {
  required_plugins {
    docker = {
      version = ">= 0.0.7"
      source  = "github.com/hashicorp/docker"
    }
  }
}
