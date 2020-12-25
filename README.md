# Docker Basics Tutorial

This repo shows some basic concepts with docker.

## Running Containers
We are using the nginx official image:
https://hub.docker.com/_/nginx

You can pull an image from docker hub using:

```
docker pull nginx:latest
```

And you can run the image using the `docker run` command:

```
docker run -d --name my-nginx nginx:latest
```

The above command runs the nginx container in *detached* mode.

You can look at its logs by running:

```
docker logs -f my-nginx
```

You can get into the running container by running:

```
docker exec -it my-nginx bash
```

On windows:

```
winpty docker exec -it my-nginx bash
```

(type `exit` to get out of the container)

You can destroy the container by using:

```
docker rm -f my-nginx
```

## Port Forwarding
The nginx container runs on port 80, but it's not open outside the container sandbox by default.  We can open a port on our host machine (say `8080`) and map it to port `80` running in the container:

```
docker run -d -p 8080:80 --name my-nginx nginx
```

Once it's running, you can visit http://localhost:8080 to access the nginx website.

## Volume mapping
What if we want to host our own content?  One way to do it is by mounting a local directory into the running container.  This is done with volume mapping.

In this repo is a subdirectory called `site`.  We can volume mount the contents of that directory by running this command from the root of this repo:

```
docker run -d -p 8080:80 -v $(pwd)/site:/usr/share/nginx/html --name my-nginx nginx
```

Now if you hit http://localhost:8080 you will see your own content.

## Creating your own image
It may be better to 'bake' your content into the image directly.  Then no volume mapping is required.  You can do this by creating your own docker image based on the `nginx` base image.

Have a look at the `Dockerfile` in this directory.

The first line (`FROM`) indicates the base image to use.

We then `COPY` the content of the `site` directory to the nginx `html` path.

Run:
```
docker build -t my-nginx:latest .
```

...then you can run your image in a new container:

```
docker run -d -p 8080:80 --name my-nginx my-nginx:latest
```