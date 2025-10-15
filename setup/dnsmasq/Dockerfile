# Use lightweight Alpine base
ARG ALPINE_VERSION=alpine:3.22

FROM $ALPINE_VERSION

ARG S6_OVERLAY_VERSION=3.2.1.0

# Install required packages
RUN apk add --no-cache dnsmasq curl bash

# Create s6 service directory for dnsmasq
RUN mkdir -p /etc/services.d/dnsmasq

# Create the run script for dnsmasq
RUN echo '#!/bin/sh' > /etc/services.d/dnsmasq/run \
 && echo 'exec dnsmasq -k -C /etc/dnsmasq.conf' >> /etc/services.d/dnsmasq/run \
 && chmod +x /etc/services.d/dnsmasq/run

# Expose DNS and DHCP ports
EXPOSE 53/tcp 53/udp 67/udp

# Install s6.
ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-noarch.tar.xz /tmp
RUN tar -C / -Jxpf /tmp/s6-overlay-noarch.tar.xz
ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-x86_64.tar.xz /tmp
RUN tar -C / -Jxpf /tmp/s6-overlay-x86_64.tar.xz

# Register s6 commands.
ENV PATH="/command:${PATH}"

# Register entrypoint.
ENTRYPOINT ["/init"]
