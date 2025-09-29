#!/bin/sh
# Fix permissions for vault logs directory
chown -R vault:vault /vault/logs
# Start vault server with proper config path
exec vault server -config=/vault/config