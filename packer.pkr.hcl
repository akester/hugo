variable "version" {
  type    = string
  default = ""
}

source "docker" "alpine" {
  commit  = true
  image   = "alpine:latest"
}

build {
  sources = ["source.docker.alpine"]

  # Upgrade the software
  provisioner "shell" {
    inline = [
      "apk update",
      "apk upgrade",
    ]
  }

  # Install wget to download hugo
  provisioner "shell" {
    inline = [
      "apk add --no-cache wget",
    ]
  }

  # Download and install hugo
  provisioner "shell" {
    inline           = [
      "wget -nv -O /tmp/hugo.tar.gz  https://github.com/gohugoio/hugo/releases/download/v${var.version}/hugo_${var.version}_linux-amd64.tar.gz",
      "cd /tmp && tar -xzvf hugo.tar.gz",
      "mv /tmp/hugo /usr/bin/hugo",
      "chmod 0755 /usr/bin/hugo",
    ]
  }

  # Remove APK cache for space
  provisioner "shell" {
    inline = [
      "rm -rf /var/cache/apk/*",
    ]
  }

  post-processor "docker-tag" {
    repository = "akester/hugo"
    tags       = [
      "${var.version}",
      "latest",
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
