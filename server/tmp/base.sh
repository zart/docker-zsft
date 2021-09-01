#!/bin/sh -ex

# minimal system preparation

# prevent installing extra crap
sed -i -e '$ainstall_weak_deps=False' -e '/^install_weak_deps=/d' /etc/dnf/dnf.conf

# remove existing crap
rm -f /etc/dnf/protected.d/sudo.conf
dnf -y erase sudo vim-minimal yum

# @core without some stuff
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
  mc tmux zip bzip2 xz

# clean up random NM leftovers
rm -f /etc/NetworkManager/system-connections/*

# when NM manages no connection, online state doesnt come, so disable wait
systemctl --no-reload disable NetworkManager-wait-online

# allow passwordless su for wheel group
sed -ie '/pam_wheel.so trust use_uid/s/^#//' /etc/pam.d/su

# remove root password
echo root: | chpasswd -e
