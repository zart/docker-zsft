## zartsoft/fedora:base image

# official fedora 34 image
FROM docker.io/library/fedora:34 as fedora

# master image
FROM fedora as base

# configure dnf
RUN echo install_weak_deps=False >> /etc/dnf/dnf.conf

# remove sudo
RUN rm /etc/dnf/protected.d/sudo.conf && dnf -y remove sudo

# basic stuff like less, ip, ping, ps, passwd, mail
RUN dnf -y install less iproute iputils procps-ng passwd mailx

# base services - systemd, ssh, syslog, mta. cron?
RUN dnf -y install systemd openssh-server openssh-clients rsyslog rsyslog-relp postfix

# security
RUN dnf -y install sssd sssd-krb5 sssd-tools krb5-workstation authselect
