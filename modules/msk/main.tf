###############################################
# 1. Configuration
###############################################

resource "aws_msk_configuration" "this" {
  name           = "${var.environment}-${var.name}-config"
  kafka_versions = [var.kafka_version]

  server_properties = <<EOF
auto.create.topics.enable=false
default.replication.factor=2
min.insync.replicas=1
num.partitions=2
unclean.leader.election.enable=false
EOF
}

# num.io.threads=8
# num.network.threads=5
# num.replica.fetchers=2
# replica.lag.time.max.ms=30000
# socket.receive.buffer.bytes=102400
# socket.request.max.bytes=104857600
# socket.send.buffer.bytes=102400

###############################################
# 2. Log Group
###############################################
resource "aws_cloudwatch_log_group" "this" {
  name              = "/aws/msk/${var.environment}-${var.name}"
  retention_in_days = 31
}

###############################################
# 3. MSK Cluster
###############################################
resource "aws_msk_cluster" "this" {
  cluster_name           = "${var.environment}-${var.name}"
  kafka_version          = var.kafka_version
  number_of_broker_nodes = length(var.availability_zones) * var.brokers_per_az

  broker_node_group_info {
    instance_type   = var.broker_instance_type
    client_subnets  = var.subnet_ids
    security_groups = var.security_group_ids

    storage_info {
      ebs_storage_info {
        volume_size = var.ebs_volume_size
        }
      }

    connectivity_info {
      public_access {
        type = "SERVICE_PROVIDED_EIPS"
        }
      }
    }

  configuration_info {
    arn      = aws_msk_configuration.this.arn
    revision = aws_msk_configuration.this.latest_revision
  }

  encryption_info {
    encryption_in_transit {
      client_broker = "TLS"
      in_cluster    = true
    }
  }

  client_authentication {
    sasl {
      iam = true
    }
  }

  logging_info {
    broker_logs {
      cloudwatch_logs {
        enabled   = true
        log_group = aws_cloudwatch_log_group.this.name
      }
    }
  }

  open_monitoring {
    prometheus {
      jmx_exporter {
        enabled_in_broker = true
      }
      node_exporter {
        enabled_in_broker = true
      }
    }
  }

  tags = merge(
    var.tags,
    { Name = "${var.environment}-${var.name}" }
  )
}
