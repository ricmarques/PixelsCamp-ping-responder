# -*- coding: utf-8 -*-
#
# Copyright (c) 2019, Bright Pixel
#
# Usage:
#
# $ echo net.ipv4.icmp_echo_ignore_all=1 | sudo tee /etc/sysctl.d/z01-disable_echo_reply.conf >/dev/null
# $ sudo systemctl restart systemd-sysctl
#
# $ docker build -t ping-responder:latest .
# $ sudo docker run --read-only -d --restart always --net=host \
#                   --init --name ping-responder ping-responder:latest \
#                   ./ping-responder.py -i eth0 -t "text in the request" -s "text in the response"
#
# Note that "--net=host" is required to respond to ICMP pings sent to the host
# and the sysctl magic is required to prevent the host from responding as well.
#


FROM python:3.7-alpine

ENV APP_ROOT="/opt/ping-responder"

RUN apk add --no-cache tcpdump

COPY --chown=0:0 requirements.txt "${APP_ROOT}"/requirements.txt
RUN pip install --upgrade -r "${APP_ROOT}/requirements.txt" && rm -f "${APP_ROOT}/requirements.txt"

COPY --chown=0:0 src/ "${APP_ROOT}"

WORKDIR ${APP_ROOT}

# The service must start as root in order to run tcpdump and open
# raw sockets. But it will drop privileges to "nobody" afterwards...
CMD ["./ping-responder.py"]


# vim: set expandtab ts=4 sw=4:
