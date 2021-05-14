# syntax=docker/dockerfile:1
FROM ubuntu:18.04

LABEL author="Mathias Lerkenfelt Brunhøj"

WORKDIR /

RUN apt-get update && apt-get install -y \
  nano \
  curl \
  openssh-server \
  && rm -f /etc/ssh/sshd_config \
  && touch /etc/ssh/authorized_keys

ADD resources/sshd_config /etc/ssh/

ADD resources/entrypoint.sh /
RUN chmod +x entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]