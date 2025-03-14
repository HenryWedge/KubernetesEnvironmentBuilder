{
  kafkaCluster(clusterName, brokerReplicas, zookeeperReplicas, namespace, host):: {
    kind: "Kafka",
    apiVersion: "kafka.strimzi.io/v1beta2",
    metadata: {
      name: clusterName,
      namespace: namespace
    },
    spec: {
      entityOperator: {
        topicOperator: {},
        userOperator: {}
      },
      kafka: {
        replicas: brokerReplicas,
        resources: {
          limits: {
            memory: "500Mi",
            cpu: "500m"
          }
        },
        config: {
          "auto.create.topics.enable": false,
          "default.replication.factor": std.min(brokerReplicas, 3),
          "inter.broker.protocol.version": "3.8",
          "min.insync.replicas": std.min(brokerReplicas, 2),
          "offsets.topic.replication.factor": std.min(brokerReplicas, 3),
          "transaction.state.log.min.isr": std.min(brokerReplicas, 2),
          "transaction.state.log.replication.factor": std.min(brokerReplicas, 3)
        },
        listeners: [
          {
            name: "plain",
            port: 9092,
            tls: false,
            type: "internal"
          },
          {
            name: "external",
            port: 9093,
            tls: false,
            type: "nodeport",
            configuration: {
              brokers: [
                {
                  advertisedHost: host,
                  broker: i
                }
                for i in std.range(0, brokerReplicas-1)
              ]
            }
          }
        ],
        metricsConfig: {
          type: "jmxPrometheusExporter",
          valueFrom: {
            configMapKeyRef: {
              name: "kafka-metrics",
              key: "kafka-metrics-config.yml"
            }
          }
        },
        storage: {
          type: "ephemeral"
        },
        version: "3.8.0"
      },
      zookeeper: {
        replicas: zookeeperReplicas,
        storage: {
          type: "ephemeral"
        }
      },
      kafkaExporter: {}
    }
  },
  kafkaUiValuesYaml(namespace, clusterName, bootstrapServer):: {
    namespace: namespace,
    service: {
      type: "NodePort"
    },
    yamlApplicationConfig: {
      kafka: {
        clusters: [
          {
            name: clusterName,
            bootstrapServers: bootstrapServer
          }
        ]
      },
      auth: {
        type: "disabled"
      },
      management: {
        health: {
          ldap: {
            enabled: false
          }
        }
      }
    }
  },
  kafkaExporterPodMonitor(clusterName, namespace):: {
    apiVersion: "monitoring.coreos.com/v1",
    kind: "PodMonitor",
    metadata: {
      name: clusterName + "-kafka-exporter-podmonitor",
      namespace: namespace,
      labels: {
        release: "prometheus"
      }
    },
    spec: {
      selector: {
        matchLabels: {
          "strimzi.io/name": clusterName + "-kafka-exporter"
        }
      },
      podMetricsEndpoints: [
        {
          path: "/metrics",
          port: "tcp-prometheus"
        }
      ]
    }
  },
  kafkaPodMonitor(clusterName, namespace):: {
    apiVersion: "monitoring.coreos.com/v1",
    kind: "PodMonitor",
    metadata: {
      name: clusterName + "-kafka-resources-metrics",
      namespace: namespace,
      labels: {
        release: "prometheus"
      }
    },
    spec: {
      selector: {
        matchLabels: {
          "strimzi.io/name": clusterName + "-kafka"
        }
      },
      podMetricsEndpoints: [
        {
          path: "/metrics",
          port: "tcp-prometheus"
        }
      ]
    }
  },
  kafkaMetricsConfigmap(namespace):: {
    kind: "ConfigMap",
    apiVersion: "v1",
    metadata: {
      name: "kafka-metrics",
      namespace: namespace,
      labels: {
        app: "strimzi"
      }
    },
    data: {
      "kafka-metrics-config.yml": "lowercaseOutputName: true\nrules:\n- pattern: kafka.server<type=(.+), name=(.+), clientId=(.+), topic=(.+), partition=(.*)><>Value\n  name: kafka_server_$1_$2\n  type: GAUGE\n  labels:\n   clientId: \"$3\"\n   topic: \"$4\"\n   partition: \"$5\"\n- pattern: kafka.server<type=(.+), name=(.+), clientId=(.+), brokerHost=(.+), brokerPort=(.+)><>Value\n  name: kafka_server_$1_$2\n  type: GAUGE\n  labels:\n   clientId: \"$3\"\n   broker: \"$4:$5\"\n- pattern: kafka.server<type=(.+), cipher=(.+), protocol=(.+), listener=(.+), networkProcessor=(.+)><>connections\n  name: kafka_server_$1_connections_tls_info\n  type: GAUGE\n  labels:\n    cipher: \"$2\"\n    protocol: \"$3\"\n    listener: \"$4\"\n    networkProcessor: \"$5\"\n- pattern: kafka.server<type=(.+), clientSoftwareName=(.+), clientSoftwareVersion=(.+), listener=(.+), networkProcessor=(.+)><>connections\n  name: kafka_server_$1_connections_software\n  type: GAUGE\n  labels:\n    clientSoftwareName: \"$2\"\n    clientSoftwareVersion: \"$3\"\n    listener: \"$4\"\n    networkProcessor: \"$5\"\n- pattern: \"kafka.server<type=(.+), listener=(.+), networkProcessor=(.+)><>(.+):\"\n  name: kafka_server_$1_$4\n  type: GAUGE\n  labels:\n   listener: \"$2\"\n   networkProcessor: \"$3\"\n- pattern: kafka.server<type=(.+), listener=(.+), networkProcessor=(.+)><>(.+)\n  name: kafka_server_$1_$4\n  type: GAUGE\n  labels:\n   listener: \"$2\"\n   networkProcessor: \"$3\"\n- pattern: kafka.(\\w+)<type=(.+), name=(.+)Percent\\w*><>MeanRate\n  name: kafka_$1_$2_$3_percent\n  type: GAUGE\n- pattern: kafka.(\\w+)<type=(.+), name=(.+)Percent\\w*><>Value\n  name: kafka_$1_$2_$3_percent\n  type: GAUGE\n- pattern: kafka.(\\w+)<type=(.+), name=(.+)Percent\\w*, (.+)=(.+)><>Value\n  name: kafka_$1_$2_$3_percent\n  type: GAUGE\n  labels:\n    \"$4\": \"$5\"\n- pattern: kafka.(\\w+)<type=(.+), name=(.+)PerSec\\w*, (.+)=(.+), (.+)=(.+)><>Count\n  name: kafka_$1_$2_$3_total\n  type: COUNTER\n  labels:\n    \"$4\": \"$5\"\n    \"$6\": \"$7\"\n- pattern: kafka.(\\w+)<type=(.+), name=(.+)PerSec\\w*, (.+)=(.+)><>Count\n  name: kafka_$1_$2_$3_total\n  type: COUNTER\n  labels:\n    \"$4\": \"$5\"\n- pattern: kafka.(\\w+)<type=(.+), name=(.+)PerSec\\w*><>Count\n  name: kafka_$1_$2_$3_total\n  type: COUNTER\n- pattern: kafka.(\\w+)<type=(.+), name=(.+), (.+)=(.+), (.+)=(.+)><>Value\n  name: kafka_$1_$2_$3\n  type: GAUGE\n  labels:\n    \"$4\": \"$5\"\n    \"$6\": \"$7\"\n- pattern: kafka.(\\w+)<type=(.+), name=(.+), (.+)=(.+)><>Value\n  name: kafka_$1_$2_$3\n  type: GAUGE\n  labels:\n    \"$4\": \"$5\"\n- pattern: kafka.(\\w+)<type=(.+), name=(.+)><>Value\n  name: kafka_$1_$2_$3\n  type: GAUGE\n- pattern: kafka.(\\w+)<type=(.+), name=(.+), (.+)=(.+), (.+)=(.+)><>Count\n  name: kafka_$1_$2_$3_count\n  type: COUNTER\n  labels:\n    \"$4\": \"$5\"\n    \"$6\": \"$7\"\n- pattern: kafka.(\\w+)<type=(.+), name=(.+), (.+)=(.*), (.+)=(.+)><>(\\d+)thPercentile\n  name: kafka_$1_$2_$3\n  type: GAUGE\n  labels:\n    \"$4\": \"$5\"\n    \"$6\": \"$7\"\n    quantile: \"0.$8\"\n- pattern: kafka.(\\w+)<type=(.+), name=(.+), (.+)=(.+)><>Count\n  name: kafka_$1_$2_$3_count\n  type: COUNTER\n  labels:\n    \"$4\": \"$5\"\n- pattern: kafka.(\\w+)<type=(.+), name=(.+), (.+)=(.*)><>(\\d+)thPercentile\n  name: kafka_$1_$2_$3\n  type: GAUGE\n  labels:\n    \"$4\": \"$5\"\n    quantile: \"0.$6\"\n- pattern: kafka.(\\w+)<type=(.+), name=(.+)><>Count\n  name: kafka_$1_$2_$3_count\n  type: COUNTER\n- pattern: kafka.(\\w+)<type=(.+), name=(.+)><>(\\d+)thPercentile\n  name: kafka_$1_$2_$3\n  type: GAUGE\n  labels:\n    quantile: \"0.$4\"\n"
    }
  }
}