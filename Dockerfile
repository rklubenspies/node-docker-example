# This is a simple Dockerfile for creating a development environment

# Use the node template as the starting point for the container.
FROM node:latest

# Set the working directory (matches the volume mounted in docker-compose.yml)
WORKDIR /home/app

# Use the "node" user to avoid permissions issues
USER node

# Set the PORT via ENV so Node can see it
ENV PORT 3000

# Expose that port to the host computer
EXPOSE 3000

# When started with "default" settings, load a bash shell
ENTRYPOINT /bin/bash