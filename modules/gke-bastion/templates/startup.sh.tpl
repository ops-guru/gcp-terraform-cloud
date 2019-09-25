#!/usr/bin/env bash
export HOME=/root
sudo apt-get install kubectl --assume-yes

mkdir -p /root/install
cd /root/install

wget https://storage.googleapis.com/kubernetes-helm/helm-v2.14.3-linux-amd64.tar.gz
tar zxvf helm-v2.14.3-linux-amd64.tar.gz
mv linux-amd64/helm /usr/local/bin

helm init --client-only
helm update
helm version