# Use lightweight Nginx image
FROM nginx:alpine

# Copy website files
COPY personal_website/ /usr/share/nginx/html/
COPY index.css index.js /usr/share/nginx/html/

# Expose HTTP port
EXPOSE 80

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]
