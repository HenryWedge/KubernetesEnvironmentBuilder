{
  buildCpuStressor(target, load):: {
    apiVersion: "chaos-mesh.org/v1alpha1",
    kind: "StressChaos",
    metadata: {
      name: "cpu-stress",
      namespace: "infra"
    },
    spec: {
      mode: "all",
      selector: {
        nodeSelectors: {
          "kubernetes.io/hostname": target
        },
        namespaces: [
          "scalablemine-hkr-sut",
          "scalablemine-hkr-kafka"
        ]
      },
      stressors: {
        cpu: {
          workers: 1,
          load: load
        }
      }
    }
  },
  buildMemoryStressor(target, memorySize): {
    apiVersion: "chaos-mesh.org/v1alpha1",
    kind: "StressChaos",
    metadata: {
      name: "memory-stress",
      namespace: "infra"
    },
    spec: {
      mode: "all",
      selector: {
        nodeSelectors: {
          "kubernetes.io/hostname": target
        },
        namespaces: [
          "scalablemine-hkr-sut",
          "scalablemine-hkr-kafka"
        ]
      },
      stressors: {
        memory: {
          workers: 1,
          size: memorySize
        }
      }
    }
  }
}