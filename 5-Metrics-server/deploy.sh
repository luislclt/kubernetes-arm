#!/bin/bash

kubectl apply -f aggregated-metrics-reader.yaml
kubectl apply -f auth-delegator.yaml
kubectl apply -f auth-reader.yaml
kubectl apply -f metrics-apiservice.yaml
kubectl apply -f resource-reader.yaml
kubectl apply -f metrics-server-deployment.yaml
kubectl apply -f metrics-server-service.yaml
