FROM alpine:3.8

USER root

ARG RUBY_BUILD_URL
ENV RUBY_BUILD_URL ${RUBY_BUILD_URL:-https://raw.githubusercontent.com/rbenv/ruby-build/master/share/ruby-build}

ARG RUBY_VERSION
ENV RUBY_VERSION ${RUBY_VERSION:-2.5.1}

ARG RUBY_OPTS
ENV RUBY_OPTS ${RUBY_OPTS:- --enable-shared --disable-rpath --enable-pthread --with-out-ext="tk" --enable-option-checking=no --disable-install-doc}

ARG JUID
ENV JUID ${JUID:-10000}

ARG JGID
ENV JGID ${JGID:-10000}

ARG BUILD_DEPS
ENV BUILD_DEPS ${BUILD_DEPS:-autoconf bison gcc glib-dev libc-dev libffi-dev linux-headers make}

ARG EXTRA_PKGS
ENV EXTRA_PKGS ${EXTRA_PKGS:-bash bzip2 bzip2-dev ca-certificates coreutils curl gdbm-dev git libxml2-dev libxslt-dev ncurses-dev openssl-dev procps readline-dev sudo readline-dev yaml-dev zlib-dev}

RUN for i in install update; do echo "${i}: --no-document"; done >/etc/gemrc

RUN apk add --no-cache $EXTRA_PKGS $BUILD_DEPS && \
    mv /bin/sh /bin/sh.bk && \
    ln /bin/bash /bin/sh && \
    wget -qO - $(wget -qO - $RUBY_BUILD_URL/$RUBY_VERSION | grep -Eo 'https?://.*ruby-.*.tar.bz2') | tar -xvjC /tmp/ && \
    cd /tmp/ruby-* && \
    ./configure $RUBY_OPTS --prefix=/usr && \
    make && \
    make install && \
    cd ~ && \
    rm -fr /tmp/ruby-* && \
    gem install bundler && \
    apk del --no-cache $BUILD_DEPS

RUN addgroup -g $JGID jenkins && \
    adduser -D -h /home/jenkins -s /bin/bash -G jenkins -u $JUID jenkins

RUN echo "jenkins ALL=(ALL) NOPASSWD:ALL" >>/etc/sudoers

USER jenkins

CMD []
