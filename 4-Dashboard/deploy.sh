#!/bin/bash

kubectl apply -f dashboard-admin-account.yaml
kubectl apply -f dashboard.yaml
kubectl apply -f dashboard-ingress.yaml

#kubectl patch deployment kubernetes-dashboard -n kube-system — patch '{"spec": {"template": {"spec": {"nodeSelector": {"beta.kubernetes.io/arch": "arm64"}}}}}'
