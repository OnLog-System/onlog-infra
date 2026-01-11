#!/bin/bash
set -euo pipefail

########################################
# 0. 기본 설정
########################################
DATA_DEV="/dev/nvme1n1"
DATA_MNT="/pgdata"
PG_VERSION="15"
PG_CLUSTER="main"

########################################
# 1. 기본 패키지
########################################
apt-get update -y
apt-get install -y \
  curl \
  wget \
  vim \
  htop \
  nvme-cli \
  xfsprogs \
  gnupg \
  lsb-release \
  ca-certificates

########################################
# 2. 디스크 포맷 (이미 포맷되어 있으면 스킵)
########################################
if ! blkid $DATA_DEV >/dev/null 2>&1; then
  mkfs.xfs $DATA_DEV
fi

########################################
# 3. 마운트
########################################
mkdir -p $DATA_MNT

DATA_UUID=$(blkid -s UUID -o value $DATA_DEV)

grep -q "$DATA_UUID" /etc/fstab || \
  echo "UUID=$DATA_UUID $DATA_MNT xfs defaults,noatime 0 2" >> /etc/fstab

mount -a

chown postgres:postgres $DATA_MNT
chmod 700 $DATA_MNT

########################################
# 4. PostgreSQL PGDG Repository
########################################
apt-get install -y gnupg curl ca-certificates

curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc \
  | gpg --dearmor \
  | tee /usr/share/keyrings/postgresql.gpg > /dev/null

echo "deb [signed-by=/usr/share/keyrings/postgresql.gpg] \
https://apt.postgresql.org/pub/repos/apt jammy-pgdg main" \
  | tee /etc/apt/sources.list.d/pgdg.list

########################################
# 5. TimescaleDB Repository
########################################
curl -fsSL https://packagecloud.io/timescale/timescaledb/gpgkey \
  | gpg --dearmor \
  | tee /usr/share/keyrings/timescaledb.gpg > /dev/null

echo "deb [signed-by=/usr/share/keyrings/timescaledb.gpg] \
https://packagecloud.io/timescale/timescaledb/ubuntu/ jammy main" \
  | tee /etc/apt/sources.list.d/timescaledb.list

apt-get update -y

########################################
# 6. PostgreSQL 15 + TimescaleDB 설치
########################################
apt-get install -y \
  postgresql-$PG_VERSION \
  postgresql-client-$PG_VERSION \
  timescaledb-2-postgresql-$PG_VERSION

########################################
# 7. 기본 클러스터 제거
########################################
pg_dropcluster --stop $PG_VERSION $PG_CLUSTER || true

########################################
# 8. EBS 경로에서 클러스터 생성 (핵심)
########################################
pg_createcluster $PG_VERSION $PG_CLUSTER \
  -d $DATA_MNT \
  --start

########################################
# 9. PostgreSQL 설정 (공식 위치)
########################################
CONF="/etc/postgresql/$PG_VERSION/$PG_CLUSTER/postgresql.conf"

grep -q "shared_preload_libraries.*timescaledb" $CONF || \
  echo "shared_preload_libraries = 'timescaledb'" >> $CONF

########################################
# 10. 서비스 재시작 및 활성화
########################################
systemctl restart postgresql@$PG_VERSION-$PG_CLUSTER
systemctl enable postgresql
