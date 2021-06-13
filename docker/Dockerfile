
FROM nginx:alpine
COPY index.html /usr/share/nginx/html/index.html

WORKDIR /docker-entrypoint.d
COPY run.sh run.sh  
RUN chmod +x run.sh