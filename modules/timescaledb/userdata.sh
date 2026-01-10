#!/bin/bash
set -euo pipefail

########################################
# 0. 기본 설정
########################################
DATA_DEV="/dev/nvme1n1"
WAL_DEV="/dev/nvme2n1"
DATA_MNT="/pgdata"
WAL_MNT="/pgwal"

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

if ! blkid $WAL_DEV >/dev/null 2>&1; then
  mkfs.xfs $WAL_DEV
fi

########################################
# 3. 마운트 디렉토리
########################################
mkdir -p $DATA_MNT $WAL_MNT

########################################
# 4. fstab 등록 (중복 방지)
########################################
DATA_UUID=$(blkid -s UUID -o value $DATA_DEV)
WAL_UUID=$(blkid -s UUID -o value $WAL_DEV)

grep -q "$DATA_UUID" /etc/fstab || \
  echo "UUID=$DATA_UUID $DATA_MNT xfs defaults,noatime 0 2" >> /etc/fstab

grep -q "$WAL_UUID" /etc/fstab || \
  echo "UUID=$WAL_UUID $WAL_MNT xfs defaults,noatime 0 2" >> /etc/fstab

mount -a

########################################
# 5. PostgreSQL PGDG Repository
########################################
install -d /usr/share/postgresql-common/pgdg
curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc \
  | gpg --dearmor -o /usr/share/postgresql-common/pgdg/apt.postgresql.org.gpg

echo "deb [signed-by=/usr/share/postgresql-common/pgdg/apt.postgresql.org.gpg] \
https://apt.postgresql.org/pub/repos/apt \
jammy-pgdg main" \
> /etc/apt/sources.list.d/pgdg.list

########################################
# 6. TimescaleDB Repository
########################################
curl -fsSL https://packagecloud.io/timescale/timescaledb/gpgkey \
  | gpg --dearmor -o /etc/apt/trusted.gpg.d/timescaledb.gpg

echo "deb https://packagecloud.io/timescale/timescaledb/ubuntu/ jammy main" \
> /etc/apt/sources.list.d/timescaledb.list

apt-get update -y

########################################
# 7. PostgreSQL 15 + TimescaleDB 설치
########################################
apt-get install -y \
  postgresql-15 \
  postgresql-client-15 \
  timescaledb-2-postgresql-15

########################################
# 8. 최초 initdb (이미 있으면 스킵)
########################################
PGDATA="/var/lib/postgresql/15/main"

if [ ! -d "$DATA_MNT/base" ]; then
  systemctl stop postgresql

  rsync -a $PGDATA/ $DATA_MNT/
  rm -rf $PGDATA
  ln -s $DATA_MNT $PGDATA
fi

########################################
# 9. PostgreSQL 설정
########################################
CONF="$DATA_MNT/postgresql.conf"

grep -q "shared_preload_libraries.*timescaledb" $CONF || \
  echo "shared_preload_libraries = 'timescaledb'" >> $CONF

grep -q "wal_directory" $CONF || \
  echo "wal_directory = '$WAL_MNT'" >> $CONF

########################################
# 10. 서비스 활성화
########################################
systemctl enable postgresql
systemctl start postgresql
