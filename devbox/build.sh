#!/bin/bash

set -xe

podman build -t localhost/devbox:latest ~/dotfiles/devbox
