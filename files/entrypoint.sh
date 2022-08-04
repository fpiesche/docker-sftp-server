#!/bin/bash

echo "Generate host keys if needed"
if [ ! -f /etc/ssh/ssh_host_ed25519_key ]; then
    ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key -N ''
fi
if [ ! -f /etc/ssh/ssh_host_rsa_key ]; then
    ssh-keygen -t rsa -b 4096 -f /etc/ssh/ssh_host_rsa_key -N ''
fi

function setup_user () {
    keyfile=$1
    username=$(basename ${keyfile%.*})

    echo "Adding user $username for $keyfile..."
    adduser --disabled-password --ingroup users --home /home/${username} ${username}
    # Set random long secure password on user so logins are possible
    pass=$(cat /dev/urandom | head -c 2048 | sha256sum | head -c 64; echo | mkpasswd)
    echo "${username}:${pass}" | chpasswd

    echo "Change ownership of /home/${username}/ to root"
    chown root:root /home/${username}
    chmod 755 /home/${username}

    echo "Set up .ssh directory for ${username}"
    mkdir /home/${username}/.ssh
    chown ${username}:users /home/${username}/.ssh

    echo "Adding authorized keys..."
    cp ${keyfile} /home/${username}/.ssh/authorized_keys
    chown -R ${username}:users /home/${username}/.ssh
    chmod 0644 /home/${username}/.ssh/authorized_keys
}

if [ "$(ls -A /authorized_keys/)" ]; then
    for filename in /authorized_keys/*; do
        setup_user $filename
    done
else
    echo "No authorized keys found to add; no users to define!"
    exit 1
fi

if [ "$(ls -A /authorized_keys/)" ]; then
    echo "Run custom scripts"
    for f in /etc/sftp.d/*; do
        echo "Running $f ..."
        /bin/sh $f
    done
else
    echo "No custom scripts found to run."
fi

echo "Launching sshd"
exec /usr/sbin/sshd -D -e
