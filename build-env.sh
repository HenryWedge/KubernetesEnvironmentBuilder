#!/bin/bash
(minikube status) || minikube start --memory 8192
./build-k8s.sh
helm/install-strimzi.sh
helm/install-kafka-ui.sh
helm/install-prometheus.sh