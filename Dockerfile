FROM nginx:latest

# optional, since this is inherited from the base image...
#EXPOSE 80

# you can run arbitrary commands while building your image
RUN apt update && \
apt install -y vim

# this is used to copy thr actual content into the image so we don't need a volume mapping
COPY ./site/ /usr/share/nginx/html/

# optional, since this is inherited form the base image...
#CMD ["nginx", "-g", "daemon off;"]