FROM nginx:alpine

RUN addgroup -g 1001 -S hextris && \
    adduser -S -D -H -u 1001 -s /sbin/nologin -G hextris hextris

COPY --chown=hextris:hextris . /usr/share/nginx/html/

RUN rm /etc/nginx/conf.d/default.conf

COPY --chown=hextris:hextris nginx.conf /etc/nginx/conf.d/default.conf

RUN mkdir -p /var/cache/nginx /var/log/nginx /var/run && \
    chown -R hextris:hextris /var/cache/nginx /var/log/nginx /usr/share/nginx/html && \
    touch /var/run/nginx.pid && chown hextris:hextris /var/run/nginx.pid && \
    sed -i 's/user nginx;/user hextris;/' /etc/nginx/nginx.conf

USER hextris

EXPOSE 8080

CMD ["nginx", "-g", "daemon off;"]