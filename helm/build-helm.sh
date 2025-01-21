DIR="$(dirname "$0")"
function check_enabled() {
  echo $1
  [ $(cat $DIR/../config.json | jq $1) == "true" ]
}

($DIR/kafka/install-strimzi.sh)
(cd $DIR/kafka/ && ./install-kafka-ui.sh)
(cd $DIR/monitor/ && ./install-prometheus.sh)
kubectl create ns sut
kubectl create ns load
