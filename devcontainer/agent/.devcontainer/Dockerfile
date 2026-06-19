FROM mcr.microsoft.com/devcontainers/base:bookworm

ENV HOMEBREW_NONINTERACTIVE=1
ENV HOMEBREW_NO_AUTO_UPDATE=1
ENV HOMEBREW_NO_ENV_HINTS=1
ENV HOMEBREW_NO_ANALYTICS=1
ENV HOMEBREW_NO_REQUIRE_TAP_TRUST=1

USER vscode
RUN /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
ENV PATH="/home/linuxbrew/.linuxbrew/bin:${PATH}"

RUN curl -fsSL https://raw.githubusercontent.com/h1st0ry3D/dotfiles/main/Brewfile -o /tmp/Brewfile \
    && brew bundle --file=/tmp/Brewfile \
    && rm /tmp/Brewfile

USER root
RUN chown -R vscode:vscode /home/linuxbrew \
    && chsh -s /bin/zsh vscode
USER vscode
CMD ["zsh", "-l"]
