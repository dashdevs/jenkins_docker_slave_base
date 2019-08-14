FROM jenkins/jnlp-slave:latest

USER root

ENV DOCKER_COMPOSE_VERSION 1.21.2

#Install rsync
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y --no-install-recommends rsync nano apt-utils python3-pip python3-dev apt-transport-https groff-base \
     ca-certificates \
     gnupg2 \
     build-essential \
     software-properties-common \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get update && \
     apt-get install -y \
     libnghttp2-dev libssl-dev libjansson-dev libcunit1-dev libev-dev libevent-dev libjemalloc-dev  binutils autoconf automake \
     autotools-dev libtool pkg-config \
    && rm -rf /var/lib/apt/lists/*

RUN wget https://github.com/nghttp2/nghttp2/releases/download/v1.32.0/nghttp2-1.32.0.tar.gz \
    && tar -xvzf nghttp2-1.32.0.tar.gz \
    && cd nghttp2-1.32.0 \
    && autoreconf -i \
    && automake \
    && autoconf \
    && ./configure \
    && make \
    && make install \
    && cd .. \
    && rm -rf nghttp2-1.32.0 \
    && rm nghttp2-1.32.0.tar.gz

RUN echo 'deb [check-valid-until=no] http://archive.debian.org/debian jessie-backports main' > /etc/apt/sources.list.d/deb-jessie-backports-main.list \
    && echo 'deb-src http://deb.debian.org/debian jessie main' > /etc/apt/sources.list.d/deb-src-jessie-main.list \
    && apt-get update \
    && apt-get -t jessie-backports install -y libssl-dev --no-install-recommends \
    && apt-get build-dep -y curl --no-install-recommends \
    && rm -rf /var/lib/apt/lists/* \
    && wget https://curl.haxx.se/download/curl-7.59.0.tar.gz \
    && tar -xvzf curl-7.59.0.tar.gz \
    && cd curl-7.59.0 \
    && ./configure --with-nghttp2=/usr/local \
        --disable-ldap --disable-sspi --without-librtmp \
        --disable-dict --disable-telnet --disable-tftp --disable-rtsp \
        --disable-pop3 --disable-imap --disable-smtp --disable-gopher --disable-smb \
    && make \
    && make install \
    && ldconfig \
    && cd .. \
    && rm -rf curl-7.59.0 \
    && rm curl-7.59.0.tar.gz \
    && rm /etc/apt/sources.list.d/deb-jessie-backports-main.list \
    && rm /etc/apt/sources.list.d/deb-src-jessie-main.list \
    && apt-get update \
    && apt-get install -y libssh2-1 --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*


RUN curl -fsSL https://download.docker.com/linux/$(. /etc/os-release; echo "$ID")/gpg | apt-key add - &&\
    add-apt-repository \
    "deb [arch=amd64] https://download.docker.com/linux/$(. /etc/os-release; echo "$ID") \
    $(lsb_release -cs) \
    stable" && \
    apt-get update && apt-get install -y docker-ce && \
    sudo curl -L https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose && \
    sudo chmod +x /usr/local/bin/docker-compose


RUN usermod -aG users jenkins

RUN sudo -H pip3 install --no-cache-dir --upgrade pip && \
    sudo -H pip3 install -U setuptools && \
    sudo -H pip3 install awscli

RUN usermod -a -G docker jenkins

# Clean up
RUN apt-get clean && \
    apt-get autoclean && \
    rm -rf /var/cache/* && \
    rm -rf /tmp/* && \
    rm -rf /var/tmp/* && \
    rm -rf /var/lib/apt/lists/*

RUN cd /usr/bin && \
  curl https://getmic.ro | bash && \
  ln -s python3-config python-config && \
  ln -s pip3 pip \
  cd /

USER jenkins

#Install s4cmd
#RUN pip3 install s4cmd
