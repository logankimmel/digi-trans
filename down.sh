#!/bin/bash
set -ex

argocd app delete prom-stack --cascade=false
argocd app delete elasticsearch --cascade=false
argocd app delete filebeat --cascade=false
argocd app delete kibana --cascade=false
argocd app delete traefik --cascade=false
argocd app delete ingress --cascade=false

server=$(argocd cluster list -o json | jq -r '.[] | select(.name=="lk-test.k8s.local") | .server')
argocd cluster rm $server

external_ip=$(kubectl --context lk-test.k8s.local get svc traefik -n traefik --template="{{range .status.loadBalancer.ingress}}{{.ip}}{{end}}")
gcloud dns record-sets transaction start --zone binbytes
gcloud dns record-sets transaction remove "${external_ip}" --name '*.test.binbytes.io' --ttl 300 --type=A --zone=binbytes
gcloud dns record-sets transaction execute --zone binbytes

export KOPS_FEATURE_FLAGS=AlphaAllowGCE
export KOPS_STATE_STORE=gs://lkimmel-clusters
kops delete cluster lk-test.k8s.local --yes