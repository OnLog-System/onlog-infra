#!/bin/bash
set -eux

############################################################
# Basic packages
############################################################
apt-get update -y
apt-get install -y \
  docker.io \
  git \
  tmux \
  htop \
  jq

############################################################
# Docker
############################################################
systemctl enable docker
systemctl start docker
usermod -aG docker ubuntu

############################################################
# Mount data volume
############################################################
DEVICE="/dev/xvdf"
MOUNT_POINT="/data"

if ! file -s ${DEVICE} | grep -q filesystem; then
  mkfs.xfs ${DEVICE}
fi

mkdir -p ${MOUNT_POINT}
mount ${DEVICE} ${MOUNT_POINT}

UUID=$(blkid -s UUID -o value ${DEVICE})
echo "UUID=${UUID} ${MOUNT_POINT} xfs defaults,nofail 0 2" >> /etc/fstab

############################################################
# Directory structure
############################################################
mkdir -p /srv/onlog
mkdir -p /srv/onlog/{api,db,grafana,batch,logs}

chown -R ubuntu:ubuntu /srv/onlog
chown -R ubuntu:ubuntu /data