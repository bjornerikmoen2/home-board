#!/bin/sh
set -e

# Set default backend port if not provided
BACKEND_PORT=${BACKEND_PORT:-8080}

# Replace environment variables in nginx config
envsubst '${BACKEND_PORT}' < /etc/nginx/conf.d/default.conf.template > /etc/nginx/conf.d/default.conf

# Start nginx
exec nginx -g 'daemon off;'

