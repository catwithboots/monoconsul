# monoconsul
Docker image with mono-complete and consul-agent

This image is a base image for DotNet application making use of Consul
The consul agent will be started in background so the Dotnet application can make use of the ENTRYPOINT or CMD

Usage (will change) :

docker pull cihatgenc/monoconsul

docker run -i -e "app=hortlak" -e "joinip=192.168.59.103" -e "dc=dc1" --name blaat cihatgenc/monoconsul

The -e option sets environment variable(s) withing the container that is used by the start script running the consul agent client

joinip (MANDATORY): The IP of the Consul cluster where the agent will register itself. This is mandatory and if no valid ip/dns name is provided it will be unable to register itself.
app (OPTIONAL): This name will be used in combination with the hostname to register in consul. In the example above the container will be registered as hortlak-7c10b32548e3. If not provided the default (only hostname) will be used.
dc (OPTIONAL): When provided it will register in the given DataCenter. If not provided the default of Consul (DC1) will be used.
