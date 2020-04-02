#!/bin/bash

kubectl apply -f dashboard-admin-account.yaml
kubectl apply -f dashboard.yaml
kubectl apply -f dashboard-ingress.yaml
