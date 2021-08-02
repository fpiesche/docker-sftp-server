#!/bin/ash

echo "Generate host keys if needed"
if [ ! -f /etc/ssh/ssh_host_ed25519_key ]; then
    ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key -N ''
fi
if [ ! -f /etc/ssh/ssh_host_rsa_key ]; then
    ssh-keygen -t rsa -b 4096 -f /etc/ssh/ssh_host_rsa_key -N ''
fi

echo "Create sftp user"
addgroup -g 1000 sftp
adduser --ingroup sftp --home /home/sftp --uid 1000 sftp
# Set random long secure password on user sftp so logins are possible
pass=$(echo date +%s | sha256sum | base64 | head -c 32; echo | mkpasswd) && \
    echo "sftp:${pass}" | chpasswd

echo "Generate ssh key pairs for the sftp user"
mkdir /home/sftp/.ssh
if [ ! -f /home/sftp/.ssh/id_ed25519 ]; then
    ssh-keygen -t ed25519 -f  /home/sftp/.ssh/id_ed25519 -N ''
fi
if [ ! -f /home/sftp/.ssh/id_rsa ]; then
    ssh-keygen -t rsa -b 4096 -f /home/sftp/.ssh/id_rsa -N ''
fi

echo "Restrict access to private keys"
chown sftp /home/sftp/.ssh/* || true
chmod 600 /home/sftp/.ssh/id_ed25519 || true
chmod 600 /home/sftp/.ssh/id_rsa || true
chmod 600 /etc/ssh/ssh_host_ed25519_key || true
chmod 600 /etc/ssh/ssh_host_rsa_key || true

echo "Add authorized keys"
if [ -d /home/sftp/.ssh/keys ]; then
    for file in /home/sftp/.ssh/keys/*; do
        echo "--- Adding $file..."
        cat $file >> /home/sftp/.ssh/authorized_keys
    done
    # Make sure we're not adding duplicate keys
    sort /home/sftp/.ssh/authorized_keys | uniq > /home/sftp/.ssh/authorized_keys.unique
    mv /home/sftp/.ssh/authorized_keys.unique /home/sftp/.ssh/authorized_keys

    echo "Set permissions for authorized_keys file"
    chmod 0644 /home/sftp/.ssh/authorized_keys
    chown sftp:sftp /home/sftp/.ssh/*
fi

echo "Run custom scripts"
if [ -d /etc/sftp.d ]; then
    for f in /etc/sftp.d/*; do
        if [ -x "$f" ]; then
            echo "Running $f ..."
            $f
        else
            echo "Could not run $f because it's missing execute permission (+x)."
        fi
    done
    unset f
fi

echo "Launching sshd"
exec /usr/sbin/sshd -D -e
