#!/bin/bash
set -euo pipefail

########################################
# 0. Base packages
########################################
export DEBIAN_FRONTEND=noninteractive

apt-get update -y
apt-get install -y \
  openjdk-17-jdk \
  git \
  awscli \
  jq \
  curl \
  ca-certificates \
  maven

########################################
# 1. Timezone
########################################
timedatectl set-timezone Asia/Seoul

########################################
# 2. Java env
########################################
JAVA_HOME_PATH="/usr/lib/jvm/java-17-openjdk-arm64"

cat <<EOF >/etc/profile.d/java.sh
export JAVA_HOME=${JAVA_HOME_PATH}
export PATH=\$JAVA_HOME/bin:\$PATH
EOF

chmod +x /etc/profile.d/java.sh

########################################
# 3. Directory layout
########################################
BASE_DIR="/opt/onlog"
SRC_DIR="${BASE_DIR}/src"
STATE_DIR="/var/lib/kafka-streams"

mkdir -p \
  ${SRC_DIR} \
  ${STATE_DIR}

chown -R ubuntu:ubuntu ${BASE_DIR} ${STATE_DIR}

########################################
# 4. SSH known_hosts for GitHub
########################################
sudo -u ubuntu mkdir -p /home/ubuntu/.ssh
sudo -u ubuntu ssh-keyscan github.com >> /home/ubuntu/.ssh/known_hosts
chmod 644 /home/ubuntu/.ssh/known_hosts

########################################
# 5. Clone onlog-pipeline repo
########################################
REPO_DIR="${SRC_DIR}/onlog-pipeline"
REPO_URL="git@github.com:OnLog-System/onlog-pipeline.git"

if [ ! -d "${REPO_DIR}" ]; then
  sudo -u ubuntu git clone ${REPO_URL} ${REPO_DIR}
fi

########################################
# 6. Done
########################################
echo "OnLog Kafka Streams EC2 bootstrap completed"
