# Demystifying istio

## What does this include?

A [KIND](https://kind.sigs.k8s.io/) based Kubernetes cluster on your notebook with:
- Istio configured with Logging&Tracing (100% of the requests)
- Grafana Tempo
- Grafana Loki
- Prometheus
- Some example applications

## Setting up the environment

> Note: this requires an x86_64 kubernetes cluster until istio supports ARM64. [Colima](https://github.com/abiosoft/colima) as a docker runtime works great.

> for M1 users: `colima start --cpu=8 -l --network-address --arch=x86_64 --memory=10` (yes, you want to pass those resources!)

- Installing the latest version of Golang (e.g. on MacOS `brew install go`)
- run `make bootstrap` which creates a [KIND](https://kind.sigs.k8s.io/) cluster and installs istio
- Create the bookinfo application with `kubectl apply -k istio-examples/bookinfo`

## Accessing services

- [Grafana](http://grafana.127.0.0.1.nip.io:8080)
- [Bookinfo](http://bookinfo.127.0.0.1.nip.io:8080/productpage)
