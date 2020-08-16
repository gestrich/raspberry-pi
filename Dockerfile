#syntax=docker/dockerfile:experimental

# Dockerfile for Raspberry Pi (v1 or Zero)

# The build container for building the Swift app from source
FROM wlisac/raspberry-pi-swift:5.1-build AS build


#Stuff that builds project -- Maybe put in script and make part of run command?
WORKDIR /app
COPY . ./
RUN chmod 777 run.sh
RUN apt-get update; apt-get install zsh

RUN rm -rf .build
RUN swift build --jobs 1
#COPY --from=build /app/.build/debug/raspberry-pi output

#WORKDIR /app

#COPY --from=build /app/.build/debug/Hello .

#CMD ["/app/run.sh", "deploy"]

# add credentials on build
ARG SSH_PRIVATE_KEY
RUN mkdir /root/.ssh/
RUN echo "${SSH_PRIVATE_KEY}" > /root/.ssh/id_rsa
RUN chmod 400 /root/.ssh/id_rsa

# make sure your domain is accepted
RUN touch /root/.ssh/known_hosts
RUN ssh-keyscan 192.168.1.217 >> /root/.ssh/known_hosts

#RUN --mount=type=ssh,id=bitbucket scp -v .build/debug/raspberry-pi pi@192.168.1.217:/home/pi/HelloWorld 
RUN scp -i ~/.ssh/id_rsa -v .build/debug/raspberry-pi pi@192.168.1.217:/home/pi/HelloWorld 
