FROM alpine:latest
MAINTAINER rstarmer@gmail.com
LABEL description='A container that writes a timestamp index.html to /clone"
RUN apk update && apk add git && mkdir /clone
COPY timestamp.sh /root/timestamp.sh
CMD /bin/sh /root/timestamp.sh
