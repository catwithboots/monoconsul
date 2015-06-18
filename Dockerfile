FROM cihatgenc/monocomplete
MAINTAINER Cihat Genc <cihat@catwithboots.com>

# based on dockerfile by Jeff Lindsay <progrium@gmail.com>

RUN apt-get update && apt-get -y -q install wget unzip supervisor

ADD https://dl.bintray.com/mitchellh/consul/0.5.2_linux_amd64.zip /tmp/consul.zip
RUN cd /bin && unzip /tmp/consul.zip && chmod +x /bin/consul && rm /tmp/consul.zip

ADD https://dl.bintray.com/mitchellh/consul/0.5.2_web_ui.zip /tmp/webui.zip
RUN mkdir /ui && cd /ui && unzip /tmp/webui.zip && rm /tmp/webui.zip && mv dist/* . && rm -rf dist

ADD https://get.docker.io/builds/Linux/x86_64/docker-1.6.1 /bin/docker
RUN chmod +x /bin/docker

RUN mkdir -p /var/log/supervisor

ADD ./config /config/

ADD ./consulagentclient /bin/consulagentclient
ADD ./check-http /bin/check-http
ADD ./check-cmd /bin/check-cmd
ADD ./supervisord.conf /etc/supervisor/conf.d/supervisord.conf

RUN chmod +x /bin/consulagentclient

EXPOSE 8300 8301 8301/udp 8302 8302/udp 8400 8500 53 53/udp
VOLUME ["/data"]

ENV SHELL /bin/bash
ENV joinip 8.8.8.8
ENV app monoconsul
ENV dc DC1

CMD []
