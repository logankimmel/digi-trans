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

#kubectl create namespace argocd
#kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
#kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
#kubectl port-forward svc/argocd-server -n argocd 8080:443


#helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
#helm repo add kube-state-metrics https://kubernetes.github.io/kube-state-metrics
#helm install prometheus prometheus-community/prometheus -n prometheus --create-namespace
#
#helm repo add grafana https://grafana.github.io/helm-charts
#helm repo update
#
#helm install my-release grafana/grafana
#G_ADMIN=$(kubectl get secret --namespace default my-release-grafana -o jsonpath="{.data.admin-password}" | base64 -d)
