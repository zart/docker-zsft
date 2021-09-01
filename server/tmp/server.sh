# install stuff
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
    whois

# fix postfix
postconf -X inet_interfaces inet_protocols
