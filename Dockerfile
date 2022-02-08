FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN=true

# Set language
ENV LANG   "C.UTF-8"
ENV LC_ALL "C.UTF-8"

# Install prerequisites
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
   software-properties-common gnupg2 curl \
   libglapi-mesa libxext-dev libxdamage-dev libxshmfence-dev libxxf86vm-dev \
   libxcb-glx0 libxcb-dri2-0 libxcb-dri3-0 libxcb-present-dev \
   ca-certificates gosu tzdata libc6 libxdamage1 libxcb-present0 \
   libxcb-sync1 libxshmfence1 libxxf86vm1 python3-gpg

# https://help.dropbox.com/installs-integrations/desktop/linux-repository
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys FC918B335044912E \
 && add-apt-repository 'deb http://linux.dropbox.com/debian buster main' \
 && apt-get update \
 && apt-get -qqy install dropbox \
 && apt-get -qqy autoclean \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN echo y | dropbox start -i && \
  mkdir /opt/dropbox && \
  mv ~/.dropbox-dist ~/.dropbox /opt/dropbox && \
  chown -R root:root /opt/dropbox && \
  chmod -R go+rX /opt/dropbox

# create user
RUN useradd -m --comment "Dropbox Daemon Account" --user-group --shell /usr/sbin/nologin dropbox

COPY docker-entrypoint.sh /

ENTRYPOINT ["/docker-entrypoint.sh"]
