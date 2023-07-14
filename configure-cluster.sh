#!/bin/env bash

set -e

TENANT=primaza-mytenant
OUTPUT_KUBECONFIG=./out/kubeconfig-sa-rhtap

## Install Primaza

kubectl apply \
    -f https://github.com/cert-manager/cert-manager/releases/download/v1.12.0/cert-manager.yaml
kubectl rollout status -n cert-manager deploy/cert-manager-webhook -w --timeout=120s

primazactl create tenant "$TENANT" --version latest

primazactl join cluster \
        --version latest \
        --tenant "$TENANT" \
        --cluster-environment self-demo \
        --environment demo

primazactl create application-namespace applications \
        --version latest \
        --tenant "$TENANT" \
        --cluster-environment self-demo

## Create the RegisteredService and the Service Endpoint Definition Secret for the PostgreSQL Service in Primaza's Control Plane
cat << EOF | kubectl apply -f -
apiVersion: primaza.io/v1alpha1
kind: RegisteredService
metadata:
  name: claim-for-appns
  namespace: "$TENANT"
spec:
  serviceClassIdentity:
  - name: type
    value: dummy
  - name: scope
    value: claim-for-appns
  serviceEndpointDefinition:
  - name: url
    value: https://my-app-for-appns-service.dev
  - name: password
    value: SomeoneThinksImAPassword
EOF

echo "use the following kubeconfig in RHTAP:"
echo

## Create ServiceAccount for RHTAP Environment
kid create identity rhtap -n applications

kubectl create rolebinding rhtap \
	-n applications \
	--role=rhtap \
	--serviceaccount=applications:rhtap
cat << EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  creationTimestamp: null
  name: rhtap
  namespace: applications
rules:
- apiGroups:
  - "*"
  resources:
  - '*'
  verbs:
  - '*'
EOF

kid get kubeconfig -n applications rhtap > "$OUTPUT_KUBECONFIG"
printf "kubeconfig to use in RHTAP saved at %s:\n\n" "$(realpath $OUTPUT_KUBECONFIG)"
cat "$OUTPUT_KUBECONFIG"
