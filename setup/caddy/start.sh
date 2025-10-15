#!/bin/sh
echo "🚀 Starting Caddy with auto-reload enabled..."
caddy run --config /etc/caddy/Caddyfile --adapter caddyfile 