FROM nginx:alpine
COPY index.html /usr/share/nginx/html/index.html

WORKDIR /docker-entrypoint.d
COPY var_sub.sh var_sub.sh
RUN chmod +x var_sub.sh