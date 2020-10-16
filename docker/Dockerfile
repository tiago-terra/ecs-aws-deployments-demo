FROM nginx:alpine
COPY nginx/index.html /usr/share/nginx/html/template.html

WORKDIR /docker-entrypoint.d
COPY envsubt.sh envsubt.sh
RUN chmod +x envsubt.sh