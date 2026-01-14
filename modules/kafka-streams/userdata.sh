#!/bin/bash
set -e

apt-get update -y
apt-get install -y openjdk-17-jdk awscli jq

# 디렉토리 구조
mkdir -p /opt/onlog/{streams-parser,streams-kpi}
mkdir -p /opt/onlog/logs/{streams-parser,streams-kpi}
mkdir -p /var/lib/kafka-streams/{streams-parser,streams-kpi}

chown -R ubuntu:ubuntu /opt/onlog /var/lib/kafka-streams
