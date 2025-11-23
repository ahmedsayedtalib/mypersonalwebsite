FROM nginx:alpine

# Copy all website files
COPY app/index.html /usr/share/nginx/html/
COPY app/index.css /usr/share/nginx/html/
COPY app/index.js /usr/share/nginx/html/

# Expose the app to port number
EXPOSE 80

