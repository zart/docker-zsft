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
    Net*er mc tmux && \
    postconf -X inet_interfaces inet_protocols && newaliases

## zartsoft/fedora:server
FROM zartsoft/fedora:base as server

# add configs and fix permissions
ADD ./base/ /
RUN find /etc/systemd -type f | xargs chmod 0644

# configure systemd units
RUN for svc in {journal,hostname,timedate,locale,login,portable,home,userdb,oom}d coredump@ journald@ ; do \
        dir=/etc/systemd/system/systemd-${svc}.service.d ; \
        mkdir $dir ; \
        ln -s ../no-bpf.conf $dir ; \
    done
RUN systemctl --no-reload set-default container.target
RUN systemctl --no-reload disable NetworkManager-wait-online.service
RUN systemctl --no-reload add-wants default systemd-user-sessions
#RUN systemctl --no-reload add-wants default rsyslog postfix NetworkManager

# remove crap
RUN rm -rf /var/cache/dnf

STOPSIGNAL 37
CMD [ "/usr/lib/systemd/systemd" ]
