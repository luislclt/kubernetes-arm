#!/bin/bash

kubectl apply -f 1-namespace.yaml
kubectl apply -f 2-rbac.yaml
kubectl apply -f 3-deployment-arm.yaml
kubectl apply -f 4-storageclass.yaml

kubectl patch storageclass nfs-ssd1 -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
kubectl patch deployment nfs-client-provisioner -n nfs-storage --patch '{"spec": {"template": {"spec": {"nodeSelector": {"beta.kubernetes.io/arch": "arm64"}}}}}'
