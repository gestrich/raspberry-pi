# Dockerfile for Raspberry Pi (v1 or Zero)

# The build container for building the Swift app from source
FROM wlisac/raspberry-pi-swift:5.1-build AS build

RUN apt-get update; apt-get install zsh; apt-get install vim;
