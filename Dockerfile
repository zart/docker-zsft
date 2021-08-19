ARG KRB5_REALM=LOCALDOMAIN.LOCAL

## base

# official fedora 34 from docker.io/library/fedora:34
#FROM zartsoft/fedora:34

# dnf updated image
FROM zartsoft/fedora:34 as base0
RUN echo install_weak_deps=False >> /etc/dnf/dnf.conf && \
    rm /etc/dnf/protected.d/sudo.conf && dnf -y remove sudo && \
    dnf -y update

# software
FROM base0 as base
RUN dnf -y install less iproute iputils procps-ng passwd mailx \
    systemd openssh-{server,clients} rsyslog postfix \
    krb5-{workstation,server} sssd{,-{krb5,tools}} authselect realmd \
    oddjob-mkhomedir Net*er mc tmux && \
    postconf -X inet_interfaces inet_protocols && newaliases

## server

FROM zartsoft/fedora:base as server

# add configs and fix permissions
ADD ./base/ /
RUN find /etc/systemd -type f | xargs chmod 0644
RUN systemctl --no-reload set-default container.target
RUN systemctl --no-reload add-wants default systemd-user-sessions
RUN for svc in {journal,hostname,timedate,locale,login,portable,home,userdb,oom}d coredump@ journald@ ; do \
        dir=/etc/systemd/system/systemd-${svc}.service.d ; \
        mkdir $dir ; \
        ln -s ../no-bpf.conf $dir ; \
    done
RUN systemctl --no-reload disable NetworkManager-wait-online.service
RUN systemctl --no-reload disable sshd.service
RUN systemctl --no-reload enable sshd.socket
RUN systemctl --no-reload add-wants default rsyslog postfix oddjobd
RUN authselect select sssd with-mkhomedir -f && authselect apply-changes
# postfix NetworkManager

# remove crap
#RUN rm -rf /var/cache/dnf

STOPSIGNAL 37
CMD [ "/usr/lib/systemd/systemd" ]
#HEALTHCHECK CMD [ "/usr/sbin/systemctl", "is-system-running" ]

## loghost

FROM server as loghost
ADD ./loghost/ /
RUN find /etc/systemd /etc/rsyslog.d -type f | xargs chmod 0644
RUN mkdir /var/log/syslog && mkfifo /var/log/syslog/everything
RUN systemctl --no-reload add-wants default consolelog

## kerberos

FROM server as krb5
ARG KRB5_REALM
ADD ./krb5/ /
RUN find /etc/systemd -type f | xargs chmod 0644
RUN systemctl --no-reload add-wants default krb5kdc kprop
RUN echo -e "[libdefaults]\n    default_realm = ${KRB5_REALM}" >> /etc/krb5.conf
