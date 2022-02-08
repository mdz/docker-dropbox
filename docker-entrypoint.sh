#!/bin/bash

DROPBOX_UID=${DROPBOX_UID:-$(/usr/bin/id -u dropbox)}
DROPBOX_GID=${DROPBOX_GID:-$(/usr/bin/id -g dropbox)}

# Set dropbox account's UID/GID, if different ones were specified
usermod -u ${DROPBOX_UID} --non-unique dropbox
groupmod -g ${DROPBOX_GID} --non-unique dropbox

# Change ownership to dropbox account on all working folders.
chown -R dropbox:dropbox ~dropbox

#  Dropbox did not shutdown properly? Remove files.
rm -f ~dropbox/.dropbox/command_socket
rm -f ~dropbox/.dropbox/iface_socket
rm -f ~dropbox/.dropbox/unlink.db
rm -f ~dropbox/.dropbox/dropbox.pid

# Set umask
umask 002

# Install if needed
echo "Copying .dropbox-dist..."
rm -rf ~dropbox/.dropbox-dist
gosu dropbox cp -R /opt/dropbox/.dropbox-dist ~dropbox/

echo "Starting..."
gosu dropbox dropbox start
pid=$(cat ~dropbox/.dropbox/dropbox.pid)
trap "kill $pid" TERM

while true; do
  gosu dropbox dropbox status
  sleep 10
done
