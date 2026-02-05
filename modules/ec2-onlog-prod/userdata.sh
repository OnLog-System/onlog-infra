#!/bin/bash
set -euo pipefail

############################################################
# Variables
############################################################
DATA_DEVICE="/dev/xvdf"
MOUNT_POINT="/data"
APP_ROOT="/srv/onlog"
LOG_FILE="/var/log/onlog-bootstrap.log"

exec > >(tee -a ${LOG_FILE}) 2>&1

echo "=== Onlog EC2 bootstrap started ==="

############################################################
# Wait for device (important on Nitro instances)
############################################################
echo "[INFO] Waiting for data device: ${DATA_DEVICE}"
for i in {1..10}; do
  if [ -b "${DATA_DEVICE}" ]; then
    echo "[INFO] Device ${DATA_DEVICE} found"
    break
  fi
  echo "[INFO] Device not found yet, retrying..."
  sleep 3
done

if [ ! -b "${DATA_DEVICE}" ]; then
  echo "[ERROR] Device ${DATA_DEVICE} not found"
  exit 1
fi

############################################################
# Basic packages
############################################################
echo "[INFO] Installing base packages"
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
# Docker setup
############################################################
echo "[INFO] Configuring Docker"
systemctl enable docker
systemctl start docker

if ! getent group docker >/dev/null; then
  groupadd docker
fi

usermod -aG docker ubuntu

############################################################
# Filesystem setup (idempotent)
############################################################
echo "[INFO] Preparing data volume"

FS_TYPE=$(blkid -o value -s TYPE "${DATA_DEVICE}" || true)

if [ -z "${FS_TYPE}" ]; then
  echo "[INFO] No filesystem found, creating XFS"
  mkfs.xfs -f "${DATA_DEVICE}"
else
  echo "[INFO] Existing filesystem detected: ${FS_TYPE}"
fi

mkdir -p "${MOUNT_POINT}"

UUID=$(blkid -s UUID -o value "${DATA_DEVICE}")

if ! grep -q "${UUID}" /etc/fstab; then
  echo "[INFO] Registering filesystem in /etc/fstab"
  echo "UUID=${UUID} ${MOUNT_POINT} xfs defaults,nofail 0 2" >> /etc/fstab
else
  echo "[INFO] /etc/fstab already contains entry"
fi

mountpoint -q "${MOUNT_POINT}" || mount "${MOUNT_POINT}"

############################################################
# Directory structure
############################################################
echo "[INFO] Creating application directories"

mkdir -p "${APP_ROOT}"/{api,db,grafana,batch,logs}

chown -R ubuntu:ubuntu "${APP_ROOT}"
chown -R ubuntu:ubuntu "${MOUNT_POINT}"

############################################################
# Finish
############################################################
echo "=== Onlog EC2 bootstrap completed successfully ==="
