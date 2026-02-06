#!/bin/bash
set -euo pipefail

############################################################
# Constants
############################################################
DATA_DEVICE="/dev/nvme1n1"
MOUNT_POINT="/data"
APP_ROOT="/srv/onlog"

echo "=== [onlog] EC2 bootstrap start ==="

############################################################
# Basic packages
############################################################
apt-get update -y
apt-get install -y \
  docker.io \
  git \
  tmux \
  htop \
  jq \
  xfsprogs \
  ca-certificates \
  curl

############################################################
# Docker
############################################################
systemctl enable docker
systemctl start docker
usermod -aG docker ubuntu

############################################################
# Data volume setup
############################################################
if [ ! -b "${DATA_DEVICE}" ]; then
  echo "[ERROR] Data device not found: ${DATA_DEVICE}"
  exit 1
fi

FS_TYPE=$(blkid -o value -s TYPE "${DATA_DEVICE}" || true)

if [ -z "${FS_TYPE}" ]; then
  echo "[INFO] Formatting ${DATA_DEVICE} as XFS"
  mkfs.xfs -f "${DATA_DEVICE}"
else
  echo "[INFO] Existing filesystem detected: ${FS_TYPE}"
fi

mkdir -p "${MOUNT_POINT}"

UUID=$(blkid -s UUID -o value "${DATA_DEVICE}")

if ! grep -q "${UUID}" /etc/fstab; then
  echo "UUID=${UUID} ${MOUNT_POINT} xfs defaults,noatime,nofail 0 2" >> /etc/fstab
fi

mountpoint -q "${MOUNT_POINT}" || mount "${MOUNT_POINT}"

############################################################
# Application directories
############################################################
mkdir -p "${APP_ROOT}"/{api,db,grafana,batch,logs}

chown -R ubuntu:ubuntu "${APP_ROOT}"
chown -R ubuntu:ubuntu "${MOUNT_POINT}"

echo "=== [onlog] EC2 bootstrap completed ==="
