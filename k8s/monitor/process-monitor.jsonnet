function(namespace, bootstrapServer){
  apiVersion: "apps/v1",
  kind: "Deployment",
  metadata: {
    name: "process-monitor",
    namespace: namespace
  },
  spec: {
    selector: {
      matchLabels: {
        app: "process-monitor",
      }
    },
    replicas: 1,
    template: {
      metadata: {
        labels: {
          app: "process-monitor",
        }
      },
      spec: {
        containers: [
          {
            name: "process-monitor",
            image: "hendrikreiter/process-monitor:0.1.0",
            imagePullPolicy: "IfNotPresent",
            ports: [
              {
                containerPort: 5000,
                name: "metrics"
              }
            ],
            env: [
              {
                name: "BOOTSTRAP_SERVER",
                value: bootstrapServer
              }
            ],
            resources: {
              limits: {
                memory: "500Mi",
                cpu: "250m"
              },
            }
          }
        ]
      }
    }
  }
}