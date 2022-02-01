# Containerised sftp server

![build](https://github.com/fpiesche/docker-sftp-server/actions/workflows/main.yml/badge.svg)

This is a containerised ssh server set up to easily share files over the internet over sftp.

# WARNING: BREAKING CHANGES AS OF VERSION 2022.02.01

I've now adjusted this image to create a unique user for each public key file given to it. This means two significant changes:

-   **Key file mount path**: As an admin, you will want to mount the volume containing your authorized key text files at `/authorized_keys` instead of `/home/sftp/.ssh/keys`.
-   **User logins**: Each user will need to use their own user name to log into the server, rather than the shared `sftp` user. You can retain the old login behaviour by simply concatenating all the authorized key text files into a single file called `sftp.pub` and mounting it at `/authorized_keys` as above.


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

  * Mount a directory of text files containing the public SSH keys you want to be able to connect as a volume at `/authorized_keys`; for each of these the entrypoint script will create a new user using the file's name as a user name and copy the key into the new user's `authorized_keys` file on container startup. A file can contain multiple public keys to allow multiple users to log in using the same name.
  * Make /etc/ssh a volume so that you can edit the configuration file if you want, and so that the container's host keys are persistent across restarts
  * If you want to run any custom shell scripts on container start, mount them into `/etc/sftp.d/` as a volume.

```console
$ docker run \
  --rm -it \
  -v sftp-config:/etc/ssh/ \
  -v sftp-init:/etc/sftp.d/ \
  -v authorized-keys:/authorized_keys/ \
  florianpiesche/sftp-server
```
