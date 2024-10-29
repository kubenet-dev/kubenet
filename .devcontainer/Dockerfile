FROM mcr.microsoft.com/devcontainers/python:3.11-bookworm

## RUN echo "deb [trusted=yes] https://netdevops.fury.site/apt/ /" | \
##    tee -a /etc/apt/sources.list.d/netdevops.list

# setup keyring for github cli
RUN sudo mkdir -p -m 755 /etc/apt/keyrings \
    && wget -qO- https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null \
    && sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null

# install containerlab and tools
RUN apt update && apt install -y --no-install-recommends direnv \
    btop \
    gh \
    iputils-ping \
    tcpdump \
    iproute2 \
    qemu-kvm \
    dnsutils \
    telnet

# install kubectl
RUN bash -c "curl -LO 'https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl'" && chmod +x kubectl && mv kubectl /usr/local/bin/

# install kind
RUN bash -c "$(curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.23.0/kind-linux-amd64)" && chmod +x kind && mv kind /usr/local/bin/

# install kubenetctl
RUN bash -c "$(curl -sL https://github.com/kubenet-dev/kubenetctl/raw/main/install.sh)"

# install choreoctl
RUN bash -c "$(curl -sL https://github.com/kform-dev/choreo/raw/main/install-choreoctl.sh)"

# install containerlab
RUN bash -c "$(curl -sL https://get.containerlab.dev)"

# install gNMIc and gNOIc
RUN bash -c "$(curl -sL https://get-gnmic.openconfig.net)" && bash -c "$(curl -sL https://get-gnoic.kmrd.dev)"

# add empty docker config files to avoid clab warnings for root user
RUN mkdir -p /root/.docker && echo "{}" > /root/.docker/config.json

# maintain SSH_AUTH_SOCK env var when using sudo
RUN mkdir -p /etc/sudoers.d && echo 'Defaults env_keep += "SSH_AUTH_SOCK"' > /etc/sudoers.d/ssh_auth_sock

# vscode user is created in the MS devcontainer image
USER vscode

# copy dclab script that is used to run the local containerlab build
# after `make build` is executed
# COPY ./.devcontainer/dclab /usr/local/bin/dclab

# create ssh key for vscode user to enable passwordless ssh to devices
RUN ssh-keygen -t ecdsa -b 256 -N "" -f ~/.ssh/id_ecdsa

# install pyenv
RUN bash -c "$(curl https://pyenv.run)"

# add empty docker config files to avoid clab warnings for vscode user
RUN mkdir -p /home/vscode/.docker && echo "{}" > /home/vscode/.docker/config.json

# setup zsh
COPY ./.devcontainer/zsh/.zshrc /home/vscode/.zshrc
COPY ./.devcontainer/zsh/.p10k.zsh /home/vscode/.p10k.zsh
COPY ./.devcontainer/zsh/install-zsh-plugins.sh /tmp/install-zsh-plugins.sh
COPY ./.devcontainer/bash/install_bash_autocompletion.sh /tmp/install_bash_autocompletion.sh
RUN bash -c "/tmp/install-zsh-plugins.sh ; /tmp/install_bash_autocompletion.sh"
