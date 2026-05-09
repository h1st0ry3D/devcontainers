FROM ubuntu:noble

ENV HOMEBREW_NO_ENV_HINTS=1
ENV EDITOR="code"

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    ca-certificates \
    curl \
    git \
    unzip \
    wget \
    zsh \
    sudo \
    && rm -rf /var/lib/apt/lists/* \
    && useradd -m -s /bin/zsh linuxbrew

WORKDIR /home/linuxbrew
RUN chown -R linuxbrew:linuxbrew /home/linuxbrew
RUN echo "linuxbrew ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

USER linuxbrew

RUN NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

ENV PATH="/home/linuxbrew/bin:/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:$PATH"

RUN echo "brew \"node\"" > /tmp/Brewfile && \
    brew bundle install --file=/tmp/Brewfile && \
    rm /tmp/Brewfile && \
    npm install -g @earendil-works/pi-coding-agent

CMD ["zsh"]