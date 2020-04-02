#!/bin/bash

sh deply.sh

kubectl apply -f external-ingress.yaml

echo "Run the script generate_auth.sh"
