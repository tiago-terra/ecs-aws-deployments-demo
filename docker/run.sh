#!/bin/sh
export HTML_FILE="/usr/share/nginx/html/index.html"
envsubst < "$HTML_FILE" > "$HTML_FILE".tmp && mv "$HTML_FILE".tmp "$HTML_FILE"
exec "$@"