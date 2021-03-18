#!/bin/bash
set -ex

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

gcloud config configurations activate stackrox
gcloud container clusters get-credentials logan-support-1 --zone us-central1 --project customers-2

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
kubectl --context gke_customers-2_us-central1_logan-support-1 apply -f traefik-manifest.yaml
argocd app sync traefik

external_ip=""
while [ -z $external_ip ]; do                                                                                                                                                                
  echo "Waiting for end point..."
  external_ip=$(kubectl --context lk-test.k8s.local get svc traefik -n traefik --template="{{range .status.loadBalancer.ingress}}{{.ip}}{{end}}")
  [ -z "$external_ip" ] && sleep 10
done

gcloud config configurations activate personal
gcloud dns record-sets transaction start --zone binbytes
gcloud dns record-sets transaction add $external_ip --name='*.test.binbytes.io' --ttl=300 --type=A --zone=binbytes
gcloud dns record-sets transaction execute --zone binbytes

kubectl  --context gke_customers-2_us-central1_logan-support-1  apply -f ingress-manifest.yaml
argocd app sync ingress

