#!/bin/sh -ex

docker pull docker.io/library/fedora:34
docker tag docker.io/library/fedora:34 zartsoft/fedora:34
docker build --target=base --tag=zartsoft/fedora:base .
