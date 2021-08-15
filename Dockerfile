## zartsoft/fedora:base image
# official fedora 34 image with dnf update
FROM zartsoft/fedora:34 as base0
RUN echo install_weak_deps=False >> /etc/dnf/dnf.conf && \
    rm /etc/dnf/protected.d/sudo.conf && dnf -y remove sudo && \
    dnf -y update

FROM base0 as base
RUN dnf -y install less iproute iputils procps-ng passwd mailx && \
    dnf -y install systemd openssh-{server,clients} rsyslog postfix dbus-daemon && \
    dnf -y install sssd{,-{krb5,tools}} krb5-workstation authselect realmd && \
    dnf -y install Net*er && \
    postconf -X inet_interfaces inet_protocols && newaliases

## zartsoft/fedora:server
FROM zartsoft/fedora:base as server

# systemd
ADD --chmod=0644 ./base/ /
CMD [ "/usr/lib/systemd/systemd" ]
STOPSIGNAL 37
RUN echo root: | chpasswd -e
RUN systemctl --no-reload set-default container.target
RUN systemctl --no-reload disable sshd.service dbus-broker.service \
                          NetworkManager-wait-online.service && \
    systemctl --no-reload enable sshd.socket dbus-daemon.service && \
    systemctl --no-reload --global disable dbus-broker.service && \
    systemctl --no-reload --global enable dbus-daemon.service && \
    systemctl --no-reload add-wants default systemd-user-sessions.service
RUN rm /etc/NetworkManager/system-connections/*
