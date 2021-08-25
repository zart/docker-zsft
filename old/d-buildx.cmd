@rem docker pull docker.io/docker/dockerfile:1.3
@rem docker buildx build -f Dockerfile.buildkit --progress=plain --target=base --tag=zartsoft/fedora:base .
docker build -f Dockerfile.buildkit --progress=plain --target=base --tag=zartsoft/fedora:base .
