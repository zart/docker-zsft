# syntax=docker/dockerfile:1

ENV maintainer=Konstantin Zemlyak <zart@zartsoft.ru>

# install most of the @core, exclude sudo and vim, add mc and tmux
# clean some crap
FROM docker.io/zartsoft/fedora:34 as base
RUN --mount=target=/var/cache/dnf,type=cache \
    echo install_weak_deps=False >> /etc/dnf/dnf.conf && \
    rm /etc/dnf/protected.d/sudo.conf && \
    dnf -y erase sudo vim-minimal yum && \
    dnf -y install \
      hostname \
      iproute \
      iputils \
      less \
      man-db \
      ncurses \
      openssh-clients \
      openssh-server \
      passwd \
      policycoreutils \
      procps-ng \
      selinux-policy-targeted \
      sssd-common \
      sssd-kcm \
      systemd \
      systemd-oomd-defaults \
      NetworkManager \
      dnf-plugins-core \
      mc tmux && \
      rm -f /etc/NetworkManager/system-connections/* && \
      systemctl --no-reload disable NetworkManager-wait-online

FROM base as systemd
ADD container.tgz /usr/lib/systemd/
CMD [ "/usr/lib/systemd/systemd" ]
STOPSIGNAL 37
