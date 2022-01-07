FROM ubuntu:20.04

EXPOSE 26657

ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8

ENV PATH="/root/.local/bin:$PATH"
ENV HOME="/root"
ENV MONIKER="nemani-node"

# Install Deps
RUN apt-get update && \
    apt-get install -y curl


# Get Latest Version from github releases
RUN curl -s https://github.com/crypto-org-chain/cronos/releases/latest | \
    tr '/" ' '\n' | \
    grep "v[0-9]\.[0-9]*\.[0-9]" | \
    head -n 1 | cut -dv -f2- | \
    tee ${HOME}/VERSION

# Download and unzip the binary from github
RUN export VERSION=$(cat ${HOME}/VERSION); curl -L https://github.com/crypto-org-chain/cronos/releases/download/v${VERSION}/cronos_${VERSION}_Linux_x86_64.tar.gz | tar -xz -C ${HOME}/

# Add cronosd to PATH
ENV PATH="$PATH:$HOME/bin"

# init cronosd
RUN cronosd init ${MONIKER} --chain-id cronosmainnet_25-1

# Download genesis.json
RUN curl https://raw.githubusercontent.com/crypto-org-chain/cronos-mainnet/master/cronosmainnet_25-1/genesis.json > ${HOME}/.cronos/config/genesis.json

# Checksum genesis.json
RUN [ "$(sha256sum ${HOME}/.cronos/config/genesis.json | awk '{print $1}')" = "58f17545056267f57a2d95f4c9c00ac1d689a580e220c5d4de96570fbbc832e1" ]

# Update app.toml for minimum-gas-prices
RUN sed -i.bak -E 's#^(minimum-gas-prices[[:space:]]+=[[:space:]]+).*$#\1"5000000000000basecro"#' ${HOME}/.cronos/config/app.toml

# Update config.toml for persistent_peers, create_empty_blocks_interval and timeout_commit
RUN sed -i.bak -E 's#^(seeds[[:space:]]+=[[:space:]]+).*$#\1"0d5cf1394a1cfde28dc8f023567222abc0f47534@cronos-seed-0.crypto.org:26656,3032073adc06d710dd512240281637c1bd0c8a7b@cronos-seed-1.crypto.org:26656,04f43116b4c6c70054d9c2b7485383df5b1ed1da@cronos-seed-2.crypto.org:26656"#' ${HOME}/.cronos/config/config.toml && \
    sed -i.bak -E 's#^(create_empty_blocks_interval[[:space:]]+=[[:space:]]+).*$#\1"5s"#' ${HOME}/.cronos/config/config.toml && \
    sed -i.bak -E 's#^(timeout_commit[[:space:]]+=[[:space:]]+).*$#\1"5s"#' ${HOME}/.cronos/config/config.toml

ENTRYPOINT ["cronosd", "start"]
