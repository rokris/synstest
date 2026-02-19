FROM nginx:1-alpine-slim@sha256:a716a2895ddba4fa7fca05e1003579f76d3d304932781426a211bc72b51f0c4e AS base

# Kopier HTML-filen til nginx sin default webroot
COPY index.html /usr/share/nginx/html/

# Eksponer port 80
EXPOSE 80

# nginx kjører automatisk i forgrunnen med alpine-imaget
CMD ["nginx", "-g", "daemon off;"]
