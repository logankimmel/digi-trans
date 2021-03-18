#!/bin/bash

#export KOPS_FEATURE_FLAGS=AlphaAllowGCE
#export KOPS_STATE_STORE=gs://lkimmel-clusters
#kops create cluster lk-test.k8s.local \
#--zones us-central1-a \
#--master-zones us-central1-a \
#--node-count 2 \
#--project lkimmel-1069 \
#--yes \
#--vpc test-net
#kops validate cluster --wait 10m
#
#argocd cluster add lk-test.k8s.local

kubectl apply -f prom-stack-manifest.yaml
argocd app sync prom-stack

kubectl apply -f elasticsearch-manifest.yaml
argocd app sync elasticsearch

kubectl apply -f filebeat-manifest.yaml
argocd app sync filebeat

#helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
#helm repo add kube-state-metrics https://kubernetes.github.io/kube-state-metrics
#helm install prometheus prometheus-community/prometheus -n prometheus --create-namespace
#
#helm repo add grafana https://grafana.github.io/helm-charts
#helm repo update
#
#helm install my-release grafana/grafana
#G_ADMIN=$(kubectl get secret --namespace default my-release-grafana -o jsonpath="{.data.admin-password}" | base64 -d)
