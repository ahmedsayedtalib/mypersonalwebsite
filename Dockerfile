FROM nginx:alpine

COPY mypersonalwebsite/index.html /usr/share/nginx/html/

COPY index.js /usr/share/nginx/html/

COPY index.css /usr/share/nginx/html/

EXPOSE 80

