#!/bin/bash
echo "Reloading DNS..."
docker compose exec dns sh -c "s6-svc -r /run/service/dnsmasq"
echo "Done."
