FROM ubuntu:noble

ENV HOMEBREW_NO_ENV_HINTS=1
ENV EDITOR="code"
ENV HOMEBREW_NO_ANALYTICS=1

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
    && useradd -m -s /bin/zsh linuxbrew \
    && echo "linuxbrew ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

WORKDIR /home/linuxbrew
RUN chown -R linuxbrew:linuxbrew /home/linuxbrew

USER linuxbrew

RUN NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

ENV PATH="/home/linuxbrew/bin:/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:$PATH"

RUN printf 'brew "node@22"\n' > /tmp/Brewfile && \
    brew bundle install --file=/tmp/Brewfile && \
    rm /tmp/Brewfile

ENV PATH="/home/linuxbrew/.linuxbrew/opt/node@22/bin:$PATH"

RUN npm install -g @earendil-works/pi-coding-agent

CMD ["zsh"]