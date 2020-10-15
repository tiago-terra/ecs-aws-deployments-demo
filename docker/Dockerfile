FROM nginx:alpine
ARG COMMIT_HASH="TEST_HASH"
ARG HTML_PATH="/usr/share/nginx/html"
ENV COMMIT_VERSION $COMMIT_HASH

COPY nginx/index.html $HTML_PATH/template.html
RUN envsubst '$COMMIT_VERSION' < "$HTML_PATH/template.html" > "$HTML_PATH/index.html"

WORKDIR /docker-entrypoint.d
COPY var_substitution.sh var_substitution.sh
RUN chmod +x var_substitution.sh