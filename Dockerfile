ARG BASE_IMAGE=pytorch/pytorch:latest

FROM ${BASE_IMAGE}

# use huawei ubuntu mirror
RUN cp -a /etc/apt/sources.list /etc/apt/sources.list.bak && \
    sed -i "s@http://.*archive.ubuntu.com@http://repo.huaweicloud.com@g" /etc/apt/sources.list && \
    sed -i "s@http://.*security.ubuntu.com@http://repo.huaweicloud.com@g" /etc/apt/sources.list

# use huawei pypi mirror
RUN pip config set global.index-url https://repo.huaweicloud.com/repository/pypi/simple/

# use tsinghua conda mirror
ADD condarc ~/.condarc

# install apt packages
RUN apt update && \
    apt install -y git vim zsh tmux curl wget openssh-server && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /var/cache/apt/*

# install oh-my-zsh
RUN git clone https://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh && \
    cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc && \
    chsh -s /usr/bin/zsh

# install starship
RUN sh -c "$(curl -fsSL https://starship.rs/install.sh)" -- --yes && \
    echo 'eval "$(starship init zsh)"\n' >> ~/.zshrc

# install frp
RUN wget https://github.com/fatedier/frp/releases/download/v0.37.0/frp_0.37.0_linux_amd64.tar.gz -O /tmp/frp.tar.gz && \
    mkdir -p /usr/local/bin && \
    mkdir -p /tmp/frp && \
    tar -xzf /tmp/frp.tar.gz -C /tmp/frp --strip-components=1 && \
    cp /tmp/frp/frps /usr/local/bin/frps && \
    cp /tmp/frp/frpc /usr/local/bin/frpc && \
    chmod +x /usr/local/bin/frps /usr/local/bin/frpc && \
    rm -rf /tmp/frp*

# conda init
RUN /opt/conda/bin/conda init bash && \
    /opt/conda/bin/conda init zsh

# install anaconda packages
RUN conda install -y -c conda-forge -c pytorch -c nvidia jupyter && \
    conda clean -ay

# configure sshd
ADD sshd_config /etc/ssh/sshd_config

# add util scripts
ADD utils /utils

# use /userhome as default workdir
VOLUME /userhome
WORKDIR /userhome

LABEL maintainer="YouSiki <you.siki@outlook.com>"
