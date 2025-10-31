ARG ALPINE_VERSION=alpine:3.22.2
ARG MKCERT_VERSION=v1.4.4

# ----------
# MAIN BUILD 
# ----------
FROM ${ALPINE_VERSION} as main

# Install dependencies.
RUN apk add --no-cache bash curl ca-certificates openssl nss go git build-base 

# Configure Bash
RUN sed -i 's|/bin/ash|/bin/bash|' /etc/passwd

# Install mkcert
RUN git clone https://github.com/FiloSottile/mkcert.git /tmp/mkcert \
    && cd /tmp/mkcert \
    && git checkout ${MKCERT_VERSION} \
    && go build -o /usr/local/bin/mkcert .
RUN mkcert -install
RUN mkcert -version
RUN apk add --no-cache coreutils \
    && ln -sf /usr/bin/gdate /usr/local/bin/date
