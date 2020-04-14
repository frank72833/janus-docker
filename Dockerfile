FROM ubuntu:18.04

RUN apt update

ARG DEBIAN_FRONTEND=noninteractive

RUN apt install --no-install-recommends --no-install-suggests -y \
    libmicrohttpd-dev \
    libjansson-dev \
    libssl-dev \
    libsofia-sip-ua-dev \
    libglib2.0-dev \ 
    libopus-dev \
    libogg-dev \
    libcurl4-openssl-dev \
    liblua5.3-dev \
    libconfig-dev \
    pkg-config \
    gengetopt \
    libtool \
    automake

RUN apt install --no-install-recommends --no-install-suggests -y \
    apt-transport-https \
    ca-certificates \
    cmake \
    git \
    gnupg1 \
    gtk-doc-tools \
    wget

WORKDIR /usr
RUN git clone https://gitlab.freedesktop.org/libnice/libnice.git
WORKDIR /usr/libnice
RUN ./autogen.sh
RUN ./configure --prefix=/usr
RUN make && make install

WORKDIR /usr
RUN wget https://github.com/cisco/libsrtp/archive/v2.2.0.tar.gz
RUN tar xfv v2.2.0.tar.gz
WORKDIR /usr/libsrtp-2.2.0
RUN ./configure --prefix=/usr --enable-openssl
RUN make shared_library && make install

WORKDIR /usr
RUN git clone https://github.com/warmcat/libwebsockets.git
WORKDIR /usr/libwebsockets
RUN mkdir build
WORKDIR /usr/libwebsockets/build
RUN cmake -DCMAKE_INSTALL_PREFIX:PATH=/usr -DCMAKE_C_FLAGS="-fpic" ..
RUN make && make install

WORKDIR /usr
RUN git clone https://github.com/meetecho/janus-gateway.git
WORKDIR /usr/janus-gateway
RUN ./autogen.sh
RUN ./configure --prefix=/opt/janus --disable-boringssl
RUN make && make install
RUN make configs

COPY conf /opt/janus/etc/janus/

COPY certificates /usr/share/certificates/

WORKDIR /usr/janus-gateway

CMD ./janus