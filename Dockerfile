# official fedora 34 from docker.io/library/fedora:34
#FROM zartsoft/fedora:34

# dnf updated image
FROM zartsoft/fedora:34 as base0
RUN echo install_weak_deps=False >> /etc/dnf/dnf.conf && \
    rm /etc/dnf/protected.d/sudo.conf && dnf -y remove sudo && \
    dnf -y update

# install required software
FROM base0 as base
RUN dnf -y install less iproute iputils procps-ng passwd mailx \
    systemd openssh-{server,clients} rsyslog postfix \
    sssd{,-{krb5,tools}} krb5-workstation authselect realmd \
    Net*er mc tmux && \
    postconf -X inet_interfaces inet_protocols && newaliases
#RUN rm -rf /var/log/*

## zartsoft/fedora:server
FROM zartsoft/fedora:base as server

# add configs and fix permissions
ADD ./base/ /
RUN find /etc/systemd -type f | xargs chmod 0644

ADD ./liete/ /tmp/liete/
RUN newusers < /tmp/liete/passwd && chpasswd -e < /tmp/liete/shadow && rm -rf /tmp/liete
RUN rm /etc/NetworkManager/system-connections/*
RUN systemctl --no-reload set-default container.target
RUN systemctl --no-reload disable NetworkManager-wait-online.service
RUN systemctl --no-reload add-wants default systemd-user-sessions
#RUN systemctl --no-reload add-wants default rsyslog postfix NetworkManager systemd-user-sessions

STOPSIGNAL 37
CMD [ "/usr/lib/systemd/systemd" ]
