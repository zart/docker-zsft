docker run ^
 --rm ^
 --name devshell ^
 --hostname devshell ^
 --tmpfs /run ^
 --tmpfs /tmp ^
 -v /sys/fs/cgroup:/sys/fs/cgroup:ro ^
 -v %CD%:/mnt/context ^
 -it ^
 -e http_proxy=%http_proxy% ^
 -e https_proxy=%https_proxy% ^
 -e ftp_proxy=%ftp_proxy% ^
 -e no_proxy=%no_proxy% ^
 --privileged ^
 zartsoft/fedora:server
