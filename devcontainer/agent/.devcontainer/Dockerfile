FROM ubuntu:noble

ENV EDITOR="code"
ENV HOMEBREW_NONINTERACTIVE=1
ENV HOMEBREW_NO_AUTO_UPDATE=1
ENV HOMEBREW_NO_ENV_HINTS=1
ENV HOMEBREW_NO_ANALYTICS=1

ARG USERNAME=linuxbrew
ARG USER_UID=1000
ARG USER_GID=${USER_UID}

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    ca-certificates \
    curl \
    git \
    zsh \
    sudo \
    && rm -rf /var/lib/apt/lists/* \
    && (id ${USER_UID} > /dev/null 2>&1 && userdel -r $(id -nu ${USER_UID}) || true) \
    && (getent group ${USER_GID} > /dev/null 2>&1 && groupdel $(getent group ${USER_GID} | cut -d: -f1) || true) \
    && groupadd --gid ${USER_GID} ${USERNAME} \
    && useradd --uid ${USER_UID} --gid ${USER_GID} -m -s /bin/zsh ${USERNAME} \
    && echo "${USERNAME} ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Install Homebrew (Linuxbrew) as linuxbrew user
USER ${USERNAME}
RUN /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
ENV PATH="/home/linuxbrew/.linuxbrew/bin:${PATH}"

# Fetch Brewfile from dotfiles repo and install packages at build time
RUN curl -fsSL https://raw.githubusercontent.com/hstorz/dotfiles/main/Brewfile -o /tmp/Brewfile \
    && brew bundle --file=/tmp/Brewfile \
    && rm /tmp/Brewfile \
    && brew update-reset 2>/dev/null || true

USER root
WORKDIR /home/linuxbrew
RUN chown -R ${USERNAME}:${USERNAME} /home/linuxbrew

USER ${USERNAME}
CMD ["zsh"]
