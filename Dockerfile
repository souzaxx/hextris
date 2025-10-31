FROM nginx:alpine

RUN addgroup -g 1001 -S hextris && \
    adduser -S -D -H -u 1001 -s /sbin/nologin -G hextris hextris

COPY . /usr/share/nginx/html/

RUN rm /etc/nginx/conf.d/default.conf
COPY <<EOF /etc/nginx/conf.d/default.conf
server {
    listen 8080;

    add_header X-Frame-Options DENY always;
    add_header X-Content-Type-Options nosniff always;
    server_tokens off;

    root /usr/share/nginx/html;
    index index.html;

    location / {
        try_files \$uri \$uri/ /index.html;
    }

    location ~* \.(css|js|png|jpg|jpeg|gif|ico|svg)$ {
        expires 1y;
        add_header Cache-Control "public";
    }
}
EOF

RUN mkdir -p /var/cache/nginx /var/log/nginx /var/run && \
    chown -R hextris:hextris /var/cache/nginx /var/log/nginx /usr/share/nginx/html && \
    touch /var/run/nginx.pid && chown hextris:hextris /var/run/nginx.pid && \
    sed -i 's/user nginx;/user hextris;/' /etc/nginx/nginx.conf

USER hextris
EXPOSE 8080

CMD ["nginx", "-g", "daemon off;"]