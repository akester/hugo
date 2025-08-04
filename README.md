# Hugo

A container for building Hugo sites in Drone CI pipelines.

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

I'm working to rebuild this container using Alpine to make it lighter weight.

This container is built using Packer and has a makefile, run `make` to start a
build.


## Mirror

If you're looking at this repo at https://github.com/akester/hugo/, know
that it's a mirror of my local code repository.  This repo is monitored though,
so any pull requests or issues will be seen.
