FROM alpine:latest
MAINTAINER your-email@example.com
LABEL description='A simple python launched Hello World web server'
RUN apk update && apk add python3
RUN echo "Hello World!" > /root/index.html
WORKDIR /root
EXPOSE 8000
CMD python3 -m http.server 8000
