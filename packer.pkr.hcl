variable "version" {
  type    = string
  default = ""
}

source "docker" "debian" {
  commit = true
  image  = "debian:13"
  changes = [
    "ENTRYPOINT [\"\"]",
    "WORKDIR [\"/tmp\"]"
  ]
}

build {
  sources = ["source.docker.debian"]

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
      "apt-get -y install wget",
      "wget -nv -O /tmp/hugo.tar.gz  https://github.com/gohugoio/hugo/releases/download/v${var.version}/hugo_extended_${var.version}_linux-amd64.tar.gz",
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
      "${var.version}",
      "latest",
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
