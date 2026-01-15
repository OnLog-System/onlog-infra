#!/bin/bash
set -euo pipefail

########################################
# 0. 기본 환경
########################################
export DEBIAN_FRONTEND=noninteractive

apt-get update -y
apt-get install -y \
  openjdk-17-jdk \
  awscli \
  jq \
  git \
  unzip \
  ca-certificates \
  curl

########################################
# 1. Timezone (중요)
########################################
timedatectl set-timezone Asia/Seoul

########################################
# 2. Java 환경 고정
########################################
JAVA_HOME_PATH="/usr/lib/jvm/java-17-openjdk-arm64"

cat <<EOF >/etc/profile.d/java.sh
export JAVA_HOME=${JAVA_HOME_PATH}
export PATH=\$JAVA_HOME/bin:\$PATH
EOF

chmod +x /etc/profile.d/java.sh

########################################
# 3. 운영 사용자
########################################
APP_USER="ubuntu"
APP_GROUP="ubuntu"

########################################
# 4. 디렉토리 구조 (고정)
########################################
BASE_DIR="/opt/onlog"
STATE_DIR="/var/lib/kafka-streams"
LOG_DIR="/opt/onlog/logs"
SRC_DIR="/opt/onlog/src"

mkdir -p \
  ${SRC_DIR} \
  ${BASE_DIR}/streams-parser \
  ${BASE_DIR}/streams-kpi \
  ${LOG_DIR}/streams-parser \
  ${LOG_DIR}/streams-kpi \
  ${STATE_DIR}/streams-parser \
  ${STATE_DIR}/streams-kpi

chown -R ${APP_USER}:${APP_GROUP} \
  ${BASE_DIR} \
  ${STATE_DIR}

########################################
# 5. SSH (GitHub pull용)
########################################
# ubuntu 유저 기준으로 SSH key 사용
SSH_DIR="/home/${APP_USER}/.ssh"
mkdir -p ${SSH_DIR}
chmod 700 ${SSH_DIR}
chown ${APP_USER}:${APP_GROUP} ${SSH_DIR}

# known_hosts에 GitHub 등록 (interactive 방지)
sudo -u ${APP_USER} ssh-keyscan github.com >> ${SSH_DIR}/known_hosts
chmod 644 ${SSH_DIR}/known_hosts

########################################
# 6. Git 기본 설정
########################################
sudo -u ${APP_USER} git config --global pull.rebase false
sudo -u ${APP_USER} git config --global init.defaultBranch main

########################################
# 7. Kafka Streams JVM 기본 옵션 파일
########################################
JVM_OPTS_DIR="/etc/onlog"
mkdir -p ${JVM_OPTS_DIR}

cat <<EOF >${JVM_OPTS_DIR}/streams-parser.env
JAVA_OPTS="
-Xms1g
-Xmx2g
-XX:+UseG1GC
-XX:MaxGCPauseMillis=200
-XX:+ExitOnOutOfMemoryError
"
EOF

cat <<EOF >${JVM_OPTS_DIR}/streams-kpi.env
JAVA_OPTS="
-Xms512m
-Xmx1g
-XX:+UseG1GC
-XX:MaxGCPauseMillis=200
-XX:+ExitOnOutOfMemoryError
"
EOF

chmod 644 ${JVM_OPTS_DIR}/*.env

########################################
# 8. Kafka Streams state dir 권한
########################################
chown -R ${APP_USER}:${APP_GROUP} ${STATE_DIR}

########################################
# 9. onlog-pipeline repo clone
########################################
REPO_URL="git@github.com:OnLog-System/onlog-pipeline.git"
REPO_DIR="/opt/onlog/src/onlog-pipeline"

if [ ! -d "${REPO_DIR}" ]; then
  sudo -u ${APP_USER} git clone ${REPO_URL} ${REPO_DIR}
else
  echo "Repository already exists: ${REPO_DIR}"
fi

########################################
# 10. 완료 로그
########################################
echo "======================================"
echo "Kafka Streams EC2 bootstrap completed"
echo "Java: $(java -version 2>&1 | head -n 1)"
echo "Timezone: $(timedatectl | grep 'Time zone')"
echo "======================================"
