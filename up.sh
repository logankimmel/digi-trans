#!/bin/bash

export KOPS_FEATURE_FLAGS=AlphaAllowGCE
export KOPS_STATE_STORE=gs://lkimmel-clusters
kops create cluster lk-test.k8s.local \
--zones us-central1-a \
--master-zones us-central1-a \
--node-count 2 \
--project lkimmel-1069 \
--yes \
--vpc test-net
kops validate cluster --wait 10m

argocd cluster add lk-test.k8s.local

kubectl --context gke_customers-2_us-central1_logan-support-1  apply -f prom-stack-manifest.yaml
argocd app sync prom-stack

kubectl --context gke_customers-2_us-central1_logan-support-1  apply -f elasticsearch-manifest.yaml
argocd app sync elasticsearch

kubectl --context gke_customers-2_us-central1_logan-support-1 apply -f filebeat-manifest.yaml
argocd app sync filebeat

kubectl  --context gke_customers-2_us-central1_logan-support-1  apply -f kibana-manifest.yaml
argocd app sync kibana

kubectl --context lk-test.k8s.local create ns traefik
kubectl --context gke_customers-2_us-central1_logan-support-1 get secret binbytes-dns -n traefik -o yaml  | kubectl --context lk-test.k8s.local apply -n traefik -f -
