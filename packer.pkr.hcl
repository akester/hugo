variable "version" {
  type    = string
  default = ""
}

source "docker" "alpine" {
  commit  = true
  image   = "alpine:latest"
  changes = [
    "ENTRYPOINT [\"/bin/sh\", \"-c\"]",
    "WORKDIR [\"/tmp\"]"
  ]
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

  # Install tools to download hugo
  provisioner "shell" {
    inline = [
      "apk add --no-cache go git gcc g++ musl-dev",
    ]
  }

  # Download and install hugo
  provisioner "shell" {
    inline           = [
      "export CGO_ENABLED=1",
      "go install --tags extended github.com/gohugoio/hugo@v${var.version}",
      "mv /root/go/bin/hugo /usr/local/bin/",

      # "wget -nv -O /tmp/hugo.tar.gz  https://github.com/gohugoio/hugo/releases/download/v${var.version}/hugo_extended_${var.version}_Linux-64bit.tar.gz",
      # "cd /tmp && tar -xzvf hugo.tar.gz",
      # "mv /tmp/hugo /usr/bin/hugo",
      # "chmod 0755 /usr/bin/hugo",
    ]
  }

  # Remove APK cache for space
  provisioner "shell" {
    inline = [
      "rm -rf /var/cache/apk/*",
    ]
  }

  # Remove root home
  provisioner "shell" {
    inline = [
      "rm -rf /root/*",
      "rm -rf /root/.*",
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
