local flink = import 'heuristics-miner-flink.jsonnet';
local objectClassifier = import 'object-classifier.jsonnet';
local astrolabe = import 'astrolabe.jsonnet';
local build = import '../util/build-util.jsonnet';
local buildManifestsFromMap = import '../util/build/build-manifests-from-map.jsonnet';
local buildManifest = import '../util/build/buildManifest.jsonnet';

function(context)
{
  flink(path, definition): buildManifest(
    path=path,
    manifestName="flink",
    manifest=flink(
      name="flink",
      definition=definition,
      externalParameter={
        namespace: context.functions.sutNamespace,
        inputTopic: context.functions.inputTopic,
        bootstrapServer: context.functions.bootstrapServer
      }
    )
  ),
  objectClassifier(path, definition): buildManifestsFromMap(
    path=path,
    manifestName="object-classifier",
    definition = definition,
    externalParameter={
      bootstrapServer: context.functions.bootstrapServer,
      topic: context.functions.inputTopic,
      namespace: context.functions.sutNamespace
    },
    buildFunction=objectClassifier
  ),
  astrolabe(path, definition):
    buildManifest(
      path=path,
      manifestName="astrolabe",
      manifest=astrolabe(
        definition=definition,
        externalParameter={
          bootstrapServer: context.functions.bootstrapServer,
          inputTopic: context.functions.inputTopic,
          namespace: context.functions.sutNamespace,
          prometheusHostName: context.functions.context.cluster
       }
    )
  )
}