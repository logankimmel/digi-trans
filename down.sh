#!/bin/bash +x

export KOPS_FEATURE_FLAGS=AlphaAllowGCE
export KOPS_STATE_STORE=gs://lkimmel-clusters
kops delete cluster lk-test.k8s.local --yes

argocd app delete prom-stack --cascade=false
argocd app delete elasticsearch --cascade=false
argocd app delete filebeat --cascade=false
argocd app delete kibana --cascade=false
argocd app delete traefik --cascade=false
argocd app delete ingress --cascade=false
