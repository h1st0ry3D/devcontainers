# Pinned base image (devcontainer release 3.0.8, Python 3.12, Debian 12 bookworm). 
# Bump the release version deliberately for reproducibility.

FROM mcr.microsoft.com/devcontainers/python:3.0.8-3.12-bookworm

# The base image grants the `vscode` user passwordless sudo. This container
# runs non-root (`remoteUser: vscode`) and does not need sudo, so remove the
# NOPASSWD entry to prevent any process in the container from escalating to root.
USER root
RUN rm -f /etc/sudoers.d/vscode
USER vscode
