FROM alpine:3.15.4

# Set up base image
RUN apk add --no-cache bash openssh openssh-sftp-server && \
    # Create /var/run/sshd/
    mkdir -p /var/run/sshd && \
    # Create /etc/sftp.d/ for init scripts
    mkdir -p /etc/sftp.d && \
    # Remove default host keys
    rm -f /etc/ssh/ssh_host_*key*

COPY files/sshd_config /etc/ssh/sshd_config
COPY files/entrypoint.sh /

EXPOSE 22

VOLUME [ "/etc/ssh/", "/etc/sftp.d/", "/authorized_keys" ]

CMD [ "/entrypoint.sh" ]
