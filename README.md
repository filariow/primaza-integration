# Primaza Integration

In this repo you can find the scripts for installing Primaza on a Cluster and preparing it for integration with RHTAP.

This repo is thought to be used togheter with the demo application [appsvc-rhtap/devfile-sample-go-basic](https://github.com/appsvc-rhtap/devfile-sample-go-basic).

## Prerequisites

- [kubectl](https://kubernetes.io/docs/tasks/tools/#kubectl)
- [primazactl](https://github.com/primaza/primazactl/releases/latest)
- [kid](https://github.com/filariow/kid/releases/latest)

## Configure the cluster

Run the script `./configure-cluster.sh`.

It installs the Cert-Manager and Primaza's Control Plane for tenant `primaza-mytenant`.
Then it configures an Application Namespace and create a dummy RegisteredService.
Finally, it create a ServiceAccount for RHTAP and export its kubeconfig.
