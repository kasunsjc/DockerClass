FROM centos
RUN apt-get update && \
    apt-get install nginx
ADD . /etc/test
EXPOSE 80
ENTRYPOINT [ "/bin/bash" ]
