#!/bin/bash

# keyinit - extract keys from root keyring for MUNGE and ssh

# MUNGE
if keyid=$(keyctl search @u user munge.key); then
    keyctl pipe $keyid | base64 -d >/etc/munge/munge.key
    chown daemon /etc/munge/munge.key
    chmod 600 /etc/munge/munge.key
    # XXX test system requires this
    if ! grep -q $(hostname) /etc/hosts; then
        ipaddr=$(ifconfig eth0|awk '/dr:/{gsub(/.*:/,"",$2);print$2}')
        echo $ipaddr $(hostname) >>/etc/hosts
    fi
fi

# SSH
sshkeys="\
ssh_host_dsa_key.pub \
ssh_host_key.pub \
ssh_host_rsa_key.pub \
ssh_host_dsa_key \
ssh_host_key \
ssh_host_rsa_key"

for key in $sshkeys; do
    if keyid=$(keyctl search @u user $key); then
        echo $key $keyid
        keyctl pipe $keyid | base64 -d >/etc/ssh/$key
        if [[ $key =~ ".pub" ]]; then
            chmod 644 /etc/ssh/$key
        else
            chmod 600 /etc/ssh/$key
        fi
    fi
done
