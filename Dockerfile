FROM nginx:alpine

LABEL description="Codyssey workstation web server"

COPY site/ /usr/share/nginx/html/

EXPOSE 80
