docker tag fedora:34 zartsoft/fedora:34
docker build --progress=plain --squash --target=base --tag=zartsoft/fedora:base .
