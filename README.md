# Docker-powered Node Dev Environment
This is an example of implementing a Node development environment within a Docker container. It's loosely based on this tutorial: <https://auth0.com/blog/use-docker-to-create-a-node-development-environment/>

## Pre-requisites
You should already have the latest version of Docker and Docker Compose installed on your system. For Windows and Mac users, the easiest way to do this is to install Docker Desktop from <https://www.docker.com/products/docker-desktop>.

To follow along with the code, you should also be comfortable with the following:
* Node
* Yarn
* Bash

If you're not comfortable with Docker and Docker Compose, don't worry because this example will teach you about it!

## How the environment is set up
The project consists of a few files:
* `server.js` our simple Node demo application
* `Dockerfile` this tells Docker how to build our container
* `docker-compose.yml` this tells Docker Compose how to spin up our container when it starts

There's also two bash scripts to make our lives easier:
* `start` this helps us properly start the Docker container without making mistakes.
* `exec` this helps us execute any terminal command within the container without making mistakes.

The bash scripts won't let you mess anything up (like start multiple instances of the same container or executing a command locally instead of on the container).

## How I built this
### Set up a basic Node app with Docker
First, we created a basic `server.js` file that contains a very simple Node application.

Next, we created a `Dockerfile` to create a basic container that we could use as a development environment. We also created a basic `docker-compose.yml` file that handles spinning up the container. Using Docker Compose is the easiest way to reliably mount our local code to the container's file system, allowing automatic code reloading without rebuilding our container (this is something you would only do in development).

### Test the container
After these files were in place, we tested our container:

    docker-compose up
    # Container was built and started

    docker image
    # An image named <project-folder>_node-dev-env now exists
    
    docker ps -a
    # A container named <project-folder>_node-dev-env_<number> now exists

    docker-compose down
    # The container was taken back down

    docker-compose run --rm --service-ports node-dev-env
    # This loads the container again and gives us a bash shell

### Use the container to execute our common node setup scripts
From within the bash shell for the container we could now set up the development dependencies and run express for the first time:

    yarn init -y
    # Initiate yarn with all default options

    yarn add express
    # Install the express package

    yarn add -D nodemon
    # Adds auto reloading functionality to express in development

Notice that executing the `yarn` commands on the Container yielded the creation of `package.json` locally within our host machine's project directory. This is because the files on our local machine were mounted as a volume inside the Container thanks to the Docker Compose file's volume mount.

### Make QOL improvements for development
To ensure that auto reloading works automatically, we also added the following to our `package.json`:

    "scripts": {
      "start": "nodemon server.js"
    }

### Start (and stop) our first express server
Back in the container bash shell, executing `yarn start` started express with nodemon auto reloading for the first time.

We can check if our server is running by navigating to <http://localhost:8080/>. Even though express is running on port 3000 inside the container, Docker's port mapping binds it to port 8080 on our local machine.

If you make a change to the response in `server.js` and save the file, you'll notice that express automatically reloads and refreshing the page in your web browser will yield the new response without rebuilding the container or re-launching it. Auto-reloading + volume mounts FTW!

To stop the container from running, just type `exit` at the container's bash prompt.

### Simplify the commands to manage the container and develop inside of it
The commands to manage containers as development environments are fairly verbose... For example, `docker-compose run --rm --service-ports <service-name>` starts the container and loads the initial bash prompt. This is great for development because you can get express started by just typing `yarn start` and then you can watch the logs... But what happens when you need to execute other commands on the container, like `yarn add`?

If your container is running and you need to execute additional commands alongside the one that's presently occupying your first bash prompt, you can do so by using the `docker exec` command. If you just try to use the `docker-compose run` command again, it'll start a whole new container instance, and you don't want that! So to fix that problem we use the `docker exec` command... but `docker exec` needs to know the container ID of the container you want to run your commands on.

To get the container ID you can use `docker ps -qf "name=<service-name>"`. After you have the ID number, you can execute a command with `docker exec -it <container-id> <command>`. This will run the given command on the given container ID if it's still running (which it should be).

**To me, this was a lot of mental work and a lot of typing... So I wrote two bash scripts to do the heavy lifting for me.**

Running `./start` will check for any running container instances of the same service name and start one up if none are found.

Running `./exec <command>` will execute the given command on the running container instance if it's running (and it'll tell you if it's not running).

These bash scripts aren't perfect... They absolutely should never be used in production or automated testing, and if you're running other services with similar names at the same time when running these scripts, they might get confused and run commands on the wrong services. So be forewarned! But for educational purposes and learning more about Docker, they worked fine for me!

## Using this example
If you're cloning this example and running it for the first time, follow these steps:
1. Ensure you have the latest versions of Docker and Docker Compose on your host computer.
2. Clone the repo and `cd` into it.
3. Run `./start` to build your first container, start it, and launch a bash shell within the container.
4. Run `yarn` to build your node_modules folder from within the container.
5. Run `yarn start` to start the express (which will be mapped to <http://localhost:8080/>)
6. Try changing the response within `server.js` and saving the file to see how auto reloading works with nodemon and Docker Compose volumes.
7. When you're done, press `Ctrl+C` to stop express and type `exit` to exit and terminate the container.

## Conclusion
I hope that this example project was easy to follow along with and it helps you with your journey using Docker as a development environment for Node.

I wouldn't have been able to create this project without the help of this tutorial: <https://auth0.com/blog/use-docker-to-create-a-node-development-environment/>. I highly recommend that you read it and follow along to improve your proficiency working with these concepts.