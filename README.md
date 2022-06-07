# Demystifying istio

## Setting up the environment

- Installing the latest version of Golang (e.g. on MacOS `brew install go`)
- run `make bootstrap` which creates a [KIND](https://kind.sigs.k8s.io/) cluster and installs istio

## Accessing services

- [Prometheus](http://prometheus.127.0.0.1.nip.io)
- [Grafana](http://grafana.127.0.0.1.nip.io)
- [Kiali](http://kiali.127.0.0.1.nip.io)
