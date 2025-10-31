ARG NODE_VERSION=node:24-alpine3.21

# Local Build
FROM $NODE_VERSION as local
RUN apk add bash
RUN sed -i 's|/bin/ash|/bin/bash|' /etc/passwd

# Live Build
FROM $NODE_VERSION as live
RUN apk add bash
RUN sed -i 's|/bin/ash|/bin/bash|' /etc/passwd