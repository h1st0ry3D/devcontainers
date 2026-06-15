FROM ubuntu:noble

ENV EDITOR="code"
ENV HOMEBREW_NONINTERACTIVE=1
ENV HOMEBREW_NO_AUTO_UPDATE=1
ENV HOMEBREW_NO_ENV_HINTS=1
ENV HOMEBREW_NO_ANALYTICS=1

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    ca-certificates \
    curl \
    git \
    zsh \
    sudo \
    && rm -rf /var/lib/apt/lists/* \
    && useradd -m -s /bin/zsh linuxbrew \
    && echo "linuxbrew ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

WORKDIR /home/linuxbrew
RUN chown -R linuxbrew:linuxbrew /home/linuxbrew

CMD ["zsh"]
