CLUSTER_NAME := "istio-demo"
KIND_VERSION := "v0.14.0"
ISTIO_VERSION := "1.14.0"

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
bootstrap: bootstrap-cluster bootstrap-istio

.PHONY: bootstrap-cluster
bootstrap-cluster: install-kind
	DOCKER_DEFAULT_PLATFORM=linux/amd64 kind create cluster --config ./hack/cluster.yaml --wait 120s --name=$(CLUSTER_NAME)

.PHONY: bootstrap-istio
bootstrap-istio: install-istioctl ensure-context
	# Install istio
	.bin/istioctl install -y --verify -f hack/istio-operator.yaml

	# addons for demo only!
	kubectl apply -f https://raw.githubusercontent.com/istio/istio/$(ISTIO_VERSION)/samples/addons/grafana.yaml
	kubectl apply -f https://raw.githubusercontent.com/istio/istio/$(ISTIO_VERSION)/samples/addons/prometheus.yaml
	kubectl apply -f https://raw.githubusercontent.com/istio/istio/$(ISTIO_VERSION)/samples/addons/kiali.yaml

	# Expose Grafana/Kialo/Prometheus
	kubectl apply -k hack/manifests

# Teardown everything
.PHONY: teardown
teardown:
	kind delete cluster --name=$(CLUSTER_NAME)


## Debug helpers using istioctl
debug-igw-%:
	.bin/istioctl pc $* -n istio-system $(shell kubectl get po -n istio-system -o name | grep ingress | head -n1)
