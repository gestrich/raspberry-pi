#syntax=docker/dockerfile:experimental

# Dockerfile for Raspberry Pi (v1 or Zero)

# The build container for building the Swift app from source
FROM wlisac/raspberry-pi-swift:5.1-build AS build

RUN apt-get update; apt-get install zsh

# add credentials on build
ARG SSH_PRIVATE_KEY
RUN mkdir /root/.ssh/
RUN echo "${SSH_PRIVATE_KEY}" > /root/.ssh/id_rsa
RUN chmod 400 /root/.ssh/id_rsa

# make sure your domain is accepted
RUN touch /root/.ssh/known_hosts
RUN ssh-keyscan 192.168.1.217 >> /root/.ssh/known_hosts
