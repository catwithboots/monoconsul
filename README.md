# Mono and Consul Agent Client in Docker
##
This project is a Docker container for DotNet (C#) applications with [Mono](http://www.mono-project.com/) and [Consul](http://www.consul.io).

It is meant as a base image for DotNet applications making use of Consul within Docker.

## Get the image
The image is available on the Docker Hub:

	$ docker pull cihatgenc/monoconsul

It is not the smallest image, but it's worth it :-) 

## Container parameters
There are a few environment parameters that the image will/can use:

**joinip (MANDATORY)**: The IP of the Consul Server where the agent will register itself. This is mandatory and if no valid ip/dns name is provided it will be unable to register itself.

Example:

	$ -e "joinip=192.168.59.103"

**app (OPTIONAL)**: This name will be used in combination with the hostname to register in consul. If not provided the default (only hostname) will be used.

Example:

	$ -e "app=MyApp"

In this example the Consul Agent client will register itself as node "MyApp-7c10b32548e3". The part after the hive will be the hostname docker gives to a container.

**dc (OPTIONAL)**: When provided it will register in the given DataCenter. If not provided the default of Consul (DC1) will be used.

Example:

	$ -e "dc=MyDC"


## Using the Container

#### Running the container as is
The container is meant to be used as a base image on which you can add your DotNet application. You can run it standalone, but the only thing you will then get is a running Consul Agent Client:

	$ docker run -i -e "joinip=192.168.59.103" --name monoconsul01 cihatgenc/monoconsul /usr/bin/supervisord

The -i is to run the container interactive

The -e is to set an environment variable, in this case the "joinip" which is the IP address of the Consul Server on which the agent client will join

The --name is to give the container a name of your choice

cihatgenc/monoconsul is the image name that is pulled from the Docker Hub

usr/bin/supervisord is the command that the container will run on start. This is needed since the image does not contain an ENTRYPOINT or CMD (will be explained further down). A docker container needs a command to execute else it will stop immediately. In the image there is a default config for supervisord to start the consul agent client.

Assuming you have a running Consul Server this command will fire up the container and the consul agent client will register itself in the Consul Server.


#### Running the container with a DotNet application
When you have a DotNet application which you want to run in Docker and make use of a local Consul Agent Client you basically just need to create your application docker image on top of monoconsul. The section "*How to add a DotNet application*" will describe on how to do this.

Assuming you have your application image, you just start your image appended with the parameters described above.

Example:

	$ docker run -e "joinip=192.168.59.103" -e "app=MyApp" -e "dc=MyDC" --name MyAppContainer cihatgenc/myapp



## How to add a DotNet application
So how can we add a DotNet application? I'll provide the steps using an example for an owin application written in C#.

First of all you will need to create a Dockerfile. I will not get into the details of a dockerfile, there is lots of information on this topic on the [Docker](https://docs.docker.com/reference/builder/) site. 

Here is an example of the Dockerfile for my C# (named Hortlak) application.

Example:

    FROM cihatgenc/monoconsul
	MAINTAINER Cihat Genc (cihat@catwithboots.com)

	RUN apt-get update && apt-get -y -q install wget unzip && mkdir -p /app
	WORKDIR /app
	RUN wget -q  http://bintray.com/artifact/download/cihatgenc/demos/Hortlak.zip && unzip Hortlak.zip && rm Hortlak.zip
	ADD ./hortlak.conf /etc/supervisor/conf.d/hortlak.conf

	EXPOSE 9000
	CMD ["/usr/bin/supervisord"]

What is this Dockerfile doing (i'll only get into the interesting stuff)? 

**FROM cihatgenc/monoconsul** - It is using the base image cihatgenc/monoconsul.

**ADD ./hortlak.conf /etc/supervisor/conf.d/hortlak.conf** - Here we add the supervisor config file for our application called hortlak.conf into the image during build. As mentioned before, since we are running (at least) 2 processes within our container (1 = Consul Agent Client, 2 = Our application called Hortlak), we will manage these with [supervisord](http://supervisord.org/introduction.html). The consul agent client part is already covered in the cihatgenc/monoconsul image. The only thing need to do is adding your application to [supervisord](http://supervisord.org/introduction.html) and it will also be automatically managed.

Here is what my hortlak.conf file contains:

**hortlak.conf**

	[program:hortlak]
	command=/usr/bin/mono-service --no-daemon -d:/app /app/Hortlak.exe

In the first line between the brackets just put [program:yourappname]. Supervisor will know your application name with this tag

Second line is the command to start your application. I'm using an owin application that can run as a (windows) service, hence the mono-service command to start the executable (you can use just mono to start console apps, see [Mono](http://www.mono-project.com/) for more information on this).

There a lot more configuration items for your application, you can get more info at [supervisord](http://supervisord.org/introduction.html). But these are the mandatory ones to get started.

**EXPOSE 9000** - My application listens on port 9000, so we will expose that port

**CMD ["/usr/bin/supervisord"]** - Since supervisord will manage the actual processes we just need to execute supervisord to start it all

And that's all there is to it. To be complete, these are the files I have for building my application image (also available in [github](https://github.com/catwithboots/hortlakdocker):

- Dockerfile
- hortlak.conf
- README.md
- LICENCE

Now I can actually build my image.

Example:

	$ docker build -t cihatgenc/hortlakdocker .

After building is done I can now start my container

Example:

	$ docker run -e "joinip=192.168.59.103" -e "app=hortlak" -e "dc=MyDC" -p 80:9000 --name hortlak01 cihatgenc/hortlakdocker

All the parameters of the command were already explained, only addition is the -p 80:9000 which means I'm binding my docker machine port 80 to the container port 9000.

That's it...
