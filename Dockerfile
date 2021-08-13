## zartsoft/fedora:base image
FROM zartsoft/fedora:34 as base
# configure dnf
RUN echo install_weak_deps=False >> /etc/dnf/dnf.conf
# remove sudo
RUN rm /etc/dnf/protected.d/sudo.conf && dnf -y remove sudo
# basic stuff like less, ip, ping, ps, passwd, mail
RUN dnf -y install less iproute iputils procps-ng passwd mailx
# base services - systemd, ssh, syslog, mta. cron?
RUN dnf -y install systemd openssh-server openssh-clients rsyslog postfix
# security
RUN dnf -y install sssd sssd-krb5 sssd-tools krb5-workstation authselect realmd
# fix postfix
RUN postconf -X inet_interfaces inet_protocols && newaliases

## zartsoft/fedora:server
FROM base as server

# systemd
ADD --chmod=0644 ./base/ /
CMD [ "/usr/lib/systemd/systemd" ]
STOPSIGNAL 37
RUN echo root: | chpasswd -e
RUN systemctl --no-reload set-default container.target
