#!/bin/ash

echo "Generate host keys if needed"
if [ ! -f /etc/ssh/ssh_host_ed25519_key ]; then
    ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key -N ''
fi
if [ ! -f /etc/ssh/ssh_host_rsa_key ]; then
    ssh-keygen -t rsa -b 4096 -f /etc/ssh/ssh_host_rsa_key -N ''
fi

echo "Create user ${SFTP_USER}"
addgroup -g 1000 ${SFTP_USER}
adduser --ingroup ${SFTP_USER} --home /home/${SFTP_USER} --uid 1000 ${SFTP_USER}
# Set random long secure password on user so logins are possible
pass=$(echo date +%s | sha256sum | base64 | head -c 32; echo | mkpasswd) && \
    echo "${SFTP_USER}:${pass}" | chpasswd

echo "Generate ssh key pairs for ${SFTP_USER}"
mkdir /home/${SFTP_USER}/.ssh
if [ ! -f /home/ ${SFTP_USER}/.ssh/id_ed25519 ]; then
    ssh-keygen -t ed25519 -f  /home/${SFTP_USER}/.ssh/id_ed25519 -N ''
fi
if [ ! -f /home/${SFTP_USER}/.ssh/id_rsa ]; then
    ssh-keygen -t rsa -b 4096 -f /home/${SFTP_USER}/.ssh/id_rsa -N ''
fi

echo "Restrict access to private keys"
chown ${SFTP_USER} /home/${SFTP_USER}/.ssh/* || true
chmod 600 /home/${SFTP_USER}/.ssh/id_ed25519 || true
chmod 600 /home/${SFTP_USER}/.ssh/id_rsa || true
chmod 600 /etc/ssh/ssh_host_ed25519_key || true
chmod 600 /etc/ssh/ssh_host_rsa_key || true

echo "Add authorized keys"
if [ -d /home/${SFTP_USER}/.ssh/keys ]; then
    for file in /home/${SFTP_USER}/.ssh/keys/*; do
        echo "--- Adding $file..."
        cat $file >> /home/${SFTP_USER}/.ssh/authorized_keys
    done
    # Make sure we're not adding duplicate keys
    sort /home/${SFTP_USER}/.ssh/authorized_keys | uniq > /home/${SFTP_USER}/.ssh/authorized_keys.unique
    mv /home/${SFTP_USER}/.ssh/authorized_keys.unique /home/${SFTP_USER}/.ssh/authorized_keys

    echo "Set permissions for authorized_keys file"
    chmod 0644 /home/${SFTP_USER}/.ssh/authorized_keys
    chown ${SFTP_USER}:${SFTP_USER} /home/${SFTP_USER}/.ssh/*
fi

echo "Run custom scripts"
for f in /etc/sftp.d/*; do
    echo "Running $f ..."
    /bin/sh $f
done

echo "Launching sshd"
exec /usr/sbin/sshd -D -e
