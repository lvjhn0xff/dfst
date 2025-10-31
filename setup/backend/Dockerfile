ARG NODE_VERSION=node:24-alpine3.21

# -----------
# LOCAL BUILD
# -----------
FROM $NODE_VERSION as local
RUN apk add bash
RUN sed -i 's|/bin/ash|/bin/bash|' /etc/passwd

# ----------
# LIVE BUILD
# ----------
FROM $NODE_VERSION as live
RUN apk add bash
RUN sed -i 's|/bin/ash|/bin/bash|' /etc/passwd