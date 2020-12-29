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

## Understanding networks
Docker networks allow containers to communicate with one another easily.

You can think of a docker (bridge) network as if it was its own physical router with its own subnet.

It's easier to understand with an example.

You can create a network using:

```
docker network create my-net
```

You can see all the networks that currently exist by running:

```
docker network ls
```

In this example, we'll re-create the `my-nginx` container on the `my-net` network:

```
docker run -d -p 8080:80 --network my-net --name my-nginx my-nginx:latest
```

The power of this becomes evident when we run another container on the same network.  As an example, let's run a postgres database on the `my-net` network:

```
docker run -d --name postgres --network my-net -e POSTGRES_PASSWORD=mysecretpassword postgres
```

(the above command also demonstrates another new docker concept.  We created an environment variable using the `-e` option.  This variable & value end up available inside the postgres container)

You can get into the postgres container using:

```
docker exec -it postgres bash
```

(As before, prefix with `winpty` if you are on windows)

The postgres container doesn't have the `curl` utility installed by default, but you can install it as a one-off by running this once you are in the container:

```
apt update && apt install -y curl
```

Once `curl` is installed, we can try communicating with the `my-nginx` container:

```
curl my-nginx:80
```

Consider this:
Since the postgres container is on the same docker network as the `my-nginx` container, it sees the other container using its container name (`my-nginx`).  What's more, it can access the other container on its "native" port (port `80`).

This means that port forwarding is only truly necessary if you need to expose a container out to the native host.  For container-to-container communication, you can use each conainer's "native" ports.  This reduces the "attack surface" available out on the host machine.

### Contacting the host network
One more tip is you can connect to anything running on the true host by using either `host.docker.internal` or `172.17.0.1`

If you are running docker desktop for Windows or macOS, you can run this form the postgres container:

```
curl host.docker.internal:8080
```

This will call out to port 8080 on the true host machine (as you will recall, 8080 is mapped to port 80 on the `my-nginx` container, so we get the nginx response).

If you are running natively in linux, this does the same thing:

```
curl 172.17.0.1:8080
```

Contacting the host network is really only useful for doing local development.  For real deployments, you should always use docker networks.