[![pipeline status](https://gitlab.com/b1g_J/flasq/badges/master/pipeline.svg)](https://gitlab.com/b1g_J/flasq/commits/master)

# flasq
For when you need a quick flask app, but are too lazy to write the basics.

# Quickstart

### Project structure
Flasq was made in a way that intends you to follow a specific structure for defining routes. Each route should get its own folder with a couple of default files. The structure should be about the following:

```
routename
├──  forms.py     # where you can define your flask forms
├──  __init__.py  # one line importing blueprint object from routes.py
├──  models.py    # where you can define your database models
└──  routes.py    # where you define your blueprint and its routes
```

Obviously you can do whatever you want, but I would recomend following that structure. It may be easiest to refer back to the auth folder to see how things are structured there when writing new sections.

### Debuging
Debuging is easy! Just run `make run`. the first time you run this, it will create a `virtualenv` with all the dependencies you need. To clean your project of all these files just run `make clean`. If you want to test the docker container, you can do that with `make build && make rund`. This will build the container, then run it. If you need to change the docker options, feel free to edit the `Makefile`. There is a convinient variable called `DOCKER_OPTIONS` that is defined at the top. Anything you put there will be an option when the container is run.

### Deploying
When you deploy your flasq app, there are two folders that will be mounted to your docker container (If you use my `docker-compose.yml`). The first mounts `/etc/letsencrypt` on the machine to the docker container. Go ahead and check the letsencrypt section for more on this. The other folder is mounts to `web/data` this is where the site database will be. This is something that you will need to change in the `docker-compose.yml`. To deploy all you need to do is build your containers and deploy:

```
make cbuild
make deploy
```

### Letsencrypt support
If you would like your website to have ssl (which is highly recommended) you can do so easily. Once you have your certs, all you need to do is add this line to your `Dockerfile`:

```
ENV CERTPATH=/path/to/your/certs
```

If `CERTPATH` is not defined, then your application will use http by default. If this is the case, then you must edit your `docker-compose.yml` so that the container binds to port 80.

This CERTPATH should be relative to where it will be mounted in the container. If you are using letsencrypt, thit will be mounted automatically. Certbot puts your certs in `/etc/letsencrpyt/live/<sitename>/` by default. More on certbot [here](https://certbot.eff.org/). When you go to deploy your application, the docker compose will mount `/etc/letsencrypt` by default. 


# Maintainer
- big_J
