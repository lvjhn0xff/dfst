ARG TRAEFIK_VERSION=traefik:v3.1-alpine

# ----------
# MAIN BUILD 
# -----------
FROM $TRAEFIK_VERSION as main

# Install and Configure Bash
RUN apk add bash
RUN sed -i 's|/bin/ash|/bin/bash|' /etc/passwd