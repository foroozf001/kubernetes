#!/bin/bash
# Script bootstraps k8s cluster with Nginx ingress controller and Metallb
kind create cluster --config=setup/config.yaml

# https://docs.projectcalico.org/getting-started/kubernetes/self-managed-onprem/onpremises#install-calico-on-nodes 
kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml
kubectl -n kube-system set env daemonset/calico-node FELIX_IGNORELOOSERPF=true

# https://kind.sigs.k8s.io/docs/user/loadbalancer/
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/master/manifests/namespace.yaml
kubectl create secret generic -n metallb-system memberlist --from-literal=secretkey="$(openssl rand -base64 128)" 
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/master/manifests/metallb.yaml
kubectl apply -f setup/metallb.cm.yaml

# https://kubernetes.github.io/ingress-nginx/deploy/#bare-metal
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.0.4/deploy/static/provider/baremetal/deploy.yaml
kubectl patch svc ingress-nginx-controller --namespace=ingress-nginx --type=json -p '[{"op":"replace","path":"/spec/type","value":"LoadBalancer"}]'