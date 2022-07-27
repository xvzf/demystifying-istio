CLUSTER_NAME := "istio-demo"
KIND_VERSION := "v0.14.0"
ISTIO_VERSION := "1.14.2"

.PHONY: install-kind
install-kind:
	go install sigs.k8s.io/kind@$(KIND_VERSION)

.PHONY: ensure-context
ensure-context:
	kubectl config use-context kind-$(CLUSTER_NAME)

.PHONY: install-istioctl
install-istioctl:
	curl -L https://istio.io/downloadIstio | ISTIO_VERSION=$(ISTIO_VERSION) sh -
	mkdir -p .bin
	mv istio-$(ISTIO_VERSION)/bin/istioctl .bin/istioctl
	rm -R istio-$(ISTIO_VERSION)

.PHONY: bootstrap
bootstrap: bootstrap-cluster bootstrap-istio bootstrap-observability

.PHONY: bootstrap-cluster
bootstrap-cluster: install-kind
	DOCKER_DEFAULT_PLATFORM=linux/amd64 kind create cluster --config ./hack/cluster.yaml --wait 120s --name=$(CLUSTER_NAME)

.PHONY: bootstrap-istio
bootstrap-istio: install-istioctl ensure-context
	# Install istio
	.bin/istioctl install -y --verify -f hack/istio-operator.yaml

# bootstrap observability
.PHONY: bootstrap-observability
bootstrap-observability:
	# Tempo
	helm repo add grafana https://grafana.github.io/helm-charts
	helm repo update
	kubectl create namespace tracing
	helm install tempo grafana/tempo -n tracing -f hack/tempo-values.yaml
	# Loki
	helm install loki grafana/loki-stack -n tracing -f hack/loki-values.yaml
	# Grafana
	helm install grafana grafana/grafana -n tracing  -f hack/grafana-values.yaml
	# custom manifests
	kubectl apply -k hack/manifests


# Teardown everything
.PHONY: teardown
teardown:
	kind delete cluster --name=$(CLUSTER_NAME)


## Debug helpers using istioctl
debug-igw-%:
	.bin/istioctl pc $* -n istio-system $(shell kubectl get po -n istio-system -o name | grep ingress | head -n1)
