FROM docker.io/library/fedora:34 as fedora
ADD server /
RUN sh -ex /tmp/base.sh

STOPSIGNAL 37
VOLUME [ "/run", "/tmp" ]
