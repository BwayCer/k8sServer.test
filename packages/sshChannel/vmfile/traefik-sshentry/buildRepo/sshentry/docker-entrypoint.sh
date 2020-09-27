#!/bin/sh
set -e

if [ ! -d "/root/.ssh" ]; then
    mkdir /root/.ssh
    cat /tmp/tercel/sshfile/authorized_keys > /root/.ssh/authorized_keys
    chmod 700 /root/.ssh
    chmod 600 /root/.ssh/authorized_keys
fi
# if our command is a valid Traefik subcommand, let's invoke it through Traefik instead
# (this allows for "docker run traefik version", etc)
if traefik "$1" --help >/dev/null 2>&1 ; then
  /usr/sbin/sshd -D &
  set -- traefik "$@"
fi

exec "$@"

