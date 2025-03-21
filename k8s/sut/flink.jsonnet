local appName = "heuristics-miner-flink";
local buildManifest = import '../util/build/buildManifest.jsonnet';

{
  buildFromConfig(
    config,
    inputTopic,
    bootstrapServer
  ):: buildManifest("sut", "flink", $.heuristicsMinerFlinkDeployment(
    namespace = "sut",
    bootstrapServer = bootstrapServer,
    inputTopic = inputTopic,
    modelTopic = config.topics.model,
    group = "heuristics-miner",
    parallelism = "1",
    sampleSize = "200",
    batchSize = "100",
    andThreshold = "0.5",
    dependencyThreshold = "0.5"
  )),
  heuristicsMinerFlinkDeployment(
      namespace,
      bootstrapServer,
      inputTopic,
      modelTopic,
      group,
      parallelism,
      sampleSize,
      batchSize,
      andThreshold,
      dependencyThreshold
    )::
  {
    apiVersion: "apps/v1",
    kind: "Deployment",
    metadata: {
      name: appName,
      namespace: namespace,
      labels: {
        app: appName
      }
    },
    spec: {
      replicas: 1,
      selector: {
        matchLabels: {
          app: appName
        }
      },
      template: {
        metadata: {
          labels: {
            app: appName
          }
        },
        spec: {
          containers: [
            {
              name: appName,
              image: "hendrikreiter/process-mining-flink:0.1.0",
              imagePullPolicy: "Always",
              env: [
                {
                   name: "BOOTSTRAP_SERVER",
                   value: bootstrapServer
                },
                {
                   name: "INPUT_TOPIC",
                   value: inputTopic
                },
                {
                    name: "MODEL_TOPIC",
                    value: modelTopic
                },
                {
                    name: "GROUP",
                    value: group
                },
                {
                    name: "PARALLELISM",
                    value: parallelism
                },
                {
                    name: 'PATH_TO_CONNECT_JAR',
                    value: "/app"
                },
                {
                    name: 'SAMPLE_SIZE',
                    value: sampleSize
                },
                {
                    name: 'BATCH_SIZE',
                    value: batchSize
                },
                {
                    name: 'AND_THRESHOLD',
                    value: andThreshold
                },
                {
                    name: 'DEPENDENCY_THRESHOLD',
                    value: dependencyThreshold
                },
              ],
              ports: [
                {
                  containerPort: 8080
                }
              ]
            }
          ]
        }
      }
    }
  }
}
