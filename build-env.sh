#!/bin/bash
(minikube status) || minikube start --memory 8192
helm/install-strimzi.sh
helm/install-kafka-ui.sh