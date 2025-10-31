ARG ALPINE_VERSION=alpine:3.22.2

# Local Build
FROM ${ALPINE_VERSION} as local
RUN apk add --no-cache bash curl ca-certificates openssl nss go git build-base \
    && sed -i 's|/bin/ash|/bin/bash|' /etc/passwd
RUN git clone https://github.com/FiloSottile/mkcert.git /tmp/mkcert \
    && cd /tmp/mkcert \
    && go build -o /usr/local/bin/mkcert .
RUN mkcert -install
RUN mkcert -version
RUN apk add --no-cache coreutils \
    && ln -sf /usr/bin/gdate /usr/local/bin/date
