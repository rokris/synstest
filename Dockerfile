FROM nginx:alpine

# Kopier HTML-filen til nginx sin default webroot
COPY index.html /usr/share/nginx/html/

# Eksponer port 80
EXPOSE 80

# nginx kjører automatisk i forgrunnen med alpine-imaget
CMD ["nginx", "-g", "daemon off;"]
