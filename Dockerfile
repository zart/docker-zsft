# syntax=docker/dockerfile:1
FROM docker.io/zartsoft/fedora:34 as base

# install most of the @core, exclude sudo and vim, add some stuff, cleanup
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
      NetworkManager-config-server \
      dnf-plugins-core \
      mc tmux zip bzip2 xz && \
      rm -f /etc/NetworkManager/system-connections/* && \
      systemctl --no-reload disable NetworkManager-wait-online

FROM docker.io/zartsoft/fedora:base as systemd
ADD container.tgz /usr/lib/systemd/
STOPSIGNAL 37
CMD [ "/usr/lib/systemd/systemd" ]


FROM systemd as common
RUN --mount=target=/var/cache/dnf,type=cache \
    dnf -y install \
      authselect \
      bind-utils \
      chrony \
      irssi \
      finger \
      ftp \
      git \
      krb5-workstation \
      lnav \
      mailx \
      mercurial \
      mlocate \
      mtr \
      mutt \
      netcat \
      oddjob-mkhomedir \
      postfix \
      realmd \
      rsync \
      rsyslog \
      sssd-krb5 \
      telnet \
      wget \
      which \
      whois && \
      postconf -X inet_interfaces inet_protocols && \
      sed -ie '/pam_wheel.so trust use_uid/s/^#//' /etc/pam.d/su
ADD common.tgz /
RUN authselect select sssd with-mkhomedir -f && authselect apply-changes
RUN systemctl --no-reload add-wants container rsyslog postfix sssd oddjobd

FROM common as loghost
ADD loghost.tgz /
RUN systemctl --no-reload add-wants container consolelog

FROM common as krb5
RUN --mount=target=/var/cache/dnf,type=cache dnf -y install krb5-server
RUN systemctl --no-reload add-wants container krb5kdc kprop

FROM common as dns
RUN --mount=target=/var/cache/dnf,type=cache dnf -y install bind

FROM common as web
RUN --mount=target=/var/cache/dnf,type=cache dnf -y install httpd-itk certbot

FROM common as news
RUN --mount=target=/var/cache/dnf,type=cache dnf -y install inn

FROM common as jabberd
RUN --mount=target=/var/cache/dnf,type=cache dnf -y install jabberd

FROM common as haproxy
RUN --mount=target=/var/cache/dnf,type=cache dnf -y install haproxy

FROM common as mail
RUN --mount=target=/var/cache/dnf,type=cache \
    dnf -y install \
      dovecot \
      dovecot-pigeonhole \
      opendkim \
      opendmarc \
      pypolicyd-spf

FROM common as postgresql
RUN --mount=target=/var/cache/dnf,type=cache dnf -y install postgresql
