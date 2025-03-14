local config = import '../config.json';
local clusterMain = import "cluster/main_cluster.jsonnet";
local kafkaMain = import 'kafka/main_kafka.jsonnet';
local loadMain = import 'load/main_load.jsonnet';
local infraMain = import 'infra/main_infra.jsonnet';
local sutMain = import 'sut/main_sut.jsonnet';
local monitorMain = import 'monitor/main_monitor.jsonnet';

clusterMain
+ kafkaMain
#+ loadMain
+ infraMain
+ sutMain
+ monitorMain