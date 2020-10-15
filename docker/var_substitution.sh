#!/bin/sh
HTML_FILE="/usr/share/nginx/html/index.html"

# The included envsubst command (not available in every docker container) will substitute the variables for us.
# They should have the format ${TEST_ENV} or $TEST_ENV
# For more information look up the command here: https://www.gnu.org/software/gettext/manual/html_node/envsubst-Invocation.html
envsubst '$DEPLOY_TYPE' < "$HTML_FILE" > "$HTML_FILE".tmp && mv "$HTML_FILE".tmp "$HTML_FILE"

# Set DEBUG=true in order to log the replaced file
if [ "$DEBUG" = true ] ; then
  exec cat $1
fi