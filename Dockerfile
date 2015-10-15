FROM ubuntu:latest

MAINTAINER Chris Pergrossi <c.pergrossi@chr1s.co>

# install dependencies
RUN apt-get update && apt-get install -y \
	build-essential libpcre3 libpcre3-dev libssl-dev wget unzip

# make our working directory
RUN mkdir /src
WORKDIR /src

# extract out the nginx source
RUN wget http://nginx.org/download/nginx-1.9.5.tar.gz && \
	tar xzvf nginx-1.9.5.tar.gz
RUN wget https://github.com/arut/nginx-rtmp-module/archive/master.zip && \
	unzip master.zip

# builds the nginx source
RUN cd nginx-* && \
	./configure --with-http_ssl_module --add-module=../nginx-rtmp-module-master && \
	make && \
	make install

# this is a convenience move that makes the configuration
# files have a shorter path
RUN mv /usr/local/nginx/conf /src/conf && \
	ln -s /src/conf /usr/local/nginx/conf

# RTMP port
EXPOSE 1935

# regular HTTP port
EXPOSE 80

# expose the nginx.conf file
VOLUME ["/src/conf"]

ADD nginx.conf /src/conf/

# run the server by default
CMD ["/usr/local/nginx/sbin/nginx"]
