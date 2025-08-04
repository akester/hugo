# Hugo

A container for building Hugo sites in Drone CI pipelines.

## Versions

`latest` is the latest version I built and have available.  It will update to
newer versions of Hugo as they are built.  You can also use a specific version
tag to lock Hugo to a more specific version should you need it.

## Usage

I include this in pipelines, an example is below:

```
---
kind: pipeline
name: build
type: docker

steps:
- name: submodules
  image: alpine/git
  commands:
  - git submodule init
  - git submodule update --recursive

- name: hugo
  image: akester/hugo
  commands:
  - hugo build

...
```

## Building

This container is built using Packer and has a makefile, run `make` to start a
build.


## Mirror

If you're looking at this repo at https://github.com/akester/hugo/, know
that it's a mirror of my local code repository.  This repo is monitored though,
so any pull requests or issues will be seen.
