# Containerised sftp server

![build](https://github.com/fpiesche/docker-sftp-server/actions/workflows/main.yml/badge.svg)

This is a containerised ssh server set up to easily share files over the internet over sftp.

# Quick reference

-   **Image Repositories**:
    - Docker Hub: [`florianpiesche/sftp-server`](https://hub.docker.com/r/florianpiesche/sftp-server)  
    - GitHub Packages: [`ghcr.io/fpiesche/sftp-server`](https://ghcr.io/fpiesche/sftp-server)  

-   **Maintained by**:  
	[Florian Piesche](https://github.com/fpiesche)

-	**Where to file issues**:  
    [https://github.com/fpiesche/docker-sftp-server/issues](https://github.com/fpiesche/docker-sftp-server/issues)

-   **Dockerfile**:
    [https://github.com/fpiesche/docker-sftp-server/blob/main/Dockerfile](https://github.com/fpiesche/docker-sftp-server/blob/main/Dockerfile)

-	**Supported architectures**:
    Each image is a multi-arch manifest for the following architectures:
    `amd64`, `arm64`, `armv7`, `armv6`

-	**Source of this description**: [Github README](https://github.com/fpiesche/docker-sftp-server/tree/main/README.md) ([history](https://github.com/fpiesche/docker-sftp-server/commits/main/README.md))

# How to use this image

  * Set the `SFTP_USER` environment variable to the user name users should use to connect to this server (default: `sftp`).
  * Mount a directory of text files containing the public SSH keys you want to be able to connect as a volume at `/home/${SFTP_USER}/.ssh/keys`; these will be copied into the user's `authorized_keys` file on container startup. Duplicates will be removed from the list. You can have multiple keys per file.
  * Make /etc/ssh a volume so that you can edit the configuration file if you want, and so that the container's host keys are persistent across restarts
  * If you want to run any custom shell scripts on container start, mount them into `/etc/sftp.d/` as a volume.

```console
$ docker run \
  --rm -it \
  -e SFTP_USER=myuser \
  -v sftp-config:/etc/ssh/ \
  -v sftp-init:/etc/sftp.d/ \
  -v authorized-keys:/home/myuser/.ssh/keys/ \
  florianpiesche/sftp-server
```
