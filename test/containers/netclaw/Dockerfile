FROM archlinux:base

# This is a disposable validation image, not an Omarchy desktop image.
# Rosetta cannot implement pacman's downloader seccomp filter; the container
# still supplies its own boundary. Keep package signature verification enabled.
RUN pacman -Syu --disable-sandbox-syscalls --noconfirm --needed bash git nodejs jq python fontconfig \
      ripgrep gawk shellcheck desktop-file-utils sudo which && \
    pacman -Scc --noconfirm && \
    useradd --create-home --shell /bin/bash tester

WORKDIR /workspace/omarchy
COPY bin/ bin/
COPY applications/ applications/
COPY default/ default/
COPY shell/ shell/
COPY test/ test/
COPY config/ config/
COPY themes/ themes/
COPY install/ install/
COPY migrations/ migrations/
COPY docs/ docs/
COPY agents/ agents/
COPY AGENTS.md README.md LICENSE ./
RUN chown -R tester:tester /workspace/omarchy
ENV OMARCHY_PATH=/workspace/omarchy
ENV PATH=/workspace/omarchy/bin:/usr/local/sbin:/usr/local/bin:/usr/bin
USER tester
CMD ["bash", "test/containers/netclaw/run.sh"]
