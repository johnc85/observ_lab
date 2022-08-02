# observ-lab
observ-lab


## Idea

The idea of this lab is to have an application with white box instrumentation. 
To achive full experience, you must have installed:
- kind
- docker
- helm
- any web browser
- python
- terraform
## Architecture

## App
Simple app with an API that returns random number between 0 and 999.

The web framework [fastapi](https://github.com/tiangolo/fastapi) was the choice.

### API Endpoints

| HTTP method   |      API endpoint      |  Description |
|----------|:-------------:|------:|
| GET |  /number    | Get random numbers |
| GET |  /metrics   | Get some metrics   |


### Running localy
Probably some libs will be necessary:

```
pip3 install fastapi uvicorn starlette_prometheus
```

On app folder:
```
➜pwd                             
~/observ-lab/api/app
```

Run
```
uvicorn main:app --reloadls
```

You can test the applicaction via curl:
```
➜curl http://127.0.0.1:8000/number
{"Number":532}%
```

You can metrics also via curl:
```
curl http://127.0.0.1:8000/metrics
# HELP python_gc_objects_collected_total Objects collected during gc
# TYPE python_gc_objects_collected_total counter
python_gc_objects_collected_total{generation="0"} 361.0
python_gc_objects_collected_total{generation="1"} 279.0
python_gc_objects_collected_total{generation="2"} 0.0
# HELP python_gc_objects_uncollectable_total Uncollectable object found during GC
# TYPE python_gc_objects_uncollectable_total counter
python_gc_objects_uncollectable_total{generation="0"} 0.0
python_gc_objects_uncollectable_total{generation="1"} 0.0
python_gc_objects_uncollectable_total{generation="2"} 0.0
# HELP python_gc_collections_total Number of times this generation was collected
# TYPE python_gc_collections_total counter
python_gc_collections_total{generation="0"} 90.0
python_gc_collections_total{generation="1"} 8.0
python_gc_collections_total{generation="2"} 0.0
# HELP python_info Python platform information
# TYPE python_info gauge
python_info{implementation="CPython",major="3",minor="9",patchlevel="12",version="3.9.12"} 1.0
# HELP starlette_requests_total Total count of requests by method and path.
# TYPE starlette_requests_total counter
starlette_requests_total{method="GET",path_template="/"} 1.0
starlette_requests_total{method="GET",path_template="/random"} 1.0
starlette_requests_total{method="GET",path_template="/number"} 1.0
starlette_requests_total{method="GET",path_template="/metrics"} 1.0
# HELP starlette_requests_created Total count of requests by method and path.
# TYPE starlette_requests_created gauge
starlette_requests_created{method="GET",path_template="/"} 1.659442850481864e+09
starlette_requests_created{method="GET",path_template="/random"} 1.659442855022638e+09
starlette_requests_created{method="GET",path_template="/number"} 1.6594428614230342e+09
starlette_requests_created{method="GET",path_template="/metrics"} 1.65944291227379e+09
# HELP starlette_responses_total Total count of responses by method, path and status codes.
# TYPE starlette_responses_total counter
starlette_responses_total{method="GET",path_template="/",status_code="404"} 1.0
starlette_responses_total{method="GET",path_template="/random",status_code="404"} 1.0
starlette_responses_total{method="GET",path_template="/number",status_code="200"} 1.0
# HELP starlette_responses_created Total count of responses by method, path and status codes.
# TYPE starlette_responses_created gauge
starlette_responses_created{method="GET",path_template="/",status_code="404"} 1.659442850482643e+09
starlette_responses_created{method="GET",path_template="/random",status_code="404"} 1.659442855023309e+09
starlette_responses_created{method="GET",path_template="/number",status_code="200"} 1.65944286142465e+09
# HELP starlette_requests_processing_time_seconds Histogram of requests processing time by path (in seconds)
# TYPE starlette_requests_processing_time_seconds histogram
starlette_requests_processing_time_seconds_bucket{le="0.005",method="GET",path_template="/"} 1.0
starlette_requests_processing_time_seconds_bucket{le="0.01",method="GET",path_template="/"} 1.0
starlette_requests_processing_time_seconds_bucket{le="0.025",method="GET",path_template="/"} 1.0
starlette_requests_processing_time_seconds_bucket{le="0.05",method="GET",path_template="/"} 1.0
starlette_requests_processing_time_seconds_bucket{le="0.075",method="GET",path_template="/"} 1.0
starlette_requests_processing_time_seconds_bucket{le="0.1",method="GET",path_template="/"} 1.0
starlette_requests_processing_time_seconds_bucket{le="0.25",method="GET",path_template="/"} 1.0
starlette_requests_processing_time_seconds_bucket{le="0.5",method="GET",path_template="/"} 1.0
starlette_requests_processing_time_seconds_bucket{le="0.75",method="GET",path_template="/"} 1.0
starlette_requests_processing_time_seconds_bucket{le="1.0",method="GET",path_template="/"} 1.0
starlette_requests_processing_time_seconds_bucket{le="2.5",method="GET",path_template="/"} 1.0
starlette_requests_processing_time_seconds_bucket{le="5.0",method="GET",path_template="/"} 1.0
starlette_requests_processing_time_seconds_bucket{le="7.5",method="GET",path_template="/"} 1.0
starlette_requests_processing_time_seconds_bucket{le="10.0",method="GET",path_template="/"} 1.0
starlette_requests_processing_time_seconds_bucket{le="+Inf",method="GET",path_template="/"} 1.0
starlette_requests_processing_time_seconds_count{method="GET",path_template="/"} 1.0
starlette_requests_processing_time_seconds_sum{method="GET",path_template="/"} 0.0006748670000007451
starlette_requests_processing_time_seconds_bucket{le="0.005",method="GET",path_template="/random"} 1.0
starlette_requests_processing_time_seconds_bucket{le="0.01",method="GET",path_template="/random"} 1.0
starlette_requests_processing_time_seconds_bucket{le="0.025",method="GET",path_template="/random"} 1.0
starlette_requests_processing_time_seconds_bucket{le="0.05",method="GET",path_template="/random"} 1.0
starlette_requests_processing_time_seconds_bucket{le="0.075",method="GET",path_template="/random"} 1.0
starlette_requests_processing_time_seconds_bucket{le="0.1",method="GET",path_template="/random"} 1.0
starlette_requests_processing_time_seconds_bucket{le="0.25",method="GET",path_template="/random"} 1.0
starlette_requests_processing_time_seconds_bucket{le="0.5",method="GET",path_template="/random"} 1.0
starlette_requests_processing_time_seconds_bucket{le="0.75",method="GET",path_template="/random"} 1.0
starlette_requests_processing_time_seconds_bucket{le="1.0",method="GET",path_template="/random"} 1.0
starlette_requests_processing_time_seconds_bucket{le="2.5",method="GET",path_template="/random"} 1.0
starlette_requests_processing_time_seconds_bucket{le="5.0",method="GET",path_template="/random"} 1.0
starlette_requests_processing_time_seconds_bucket{le="7.5",method="GET",path_template="/random"} 1.0
starlette_requests_processing_time_seconds_bucket{le="10.0",method="GET",path_template="/random"} 1.0
starlette_requests_processing_time_seconds_bucket{le="+Inf",method="GET",path_template="/random"} 1.0
starlette_requests_processing_time_seconds_count{method="GET",path_template="/random"} 1.0
starlette_requests_processing_time_seconds_sum{method="GET",path_template="/random"} 0.0005281830000001264
starlette_requests_processing_time_seconds_bucket{le="0.005",method="GET",path_template="/number"} 1.0
starlette_requests_processing_time_seconds_bucket{le="0.01",method="GET",path_template="/number"} 1.0
starlette_requests_processing_time_seconds_bucket{le="0.025",method="GET",path_template="/number"} 1.0
starlette_requests_processing_time_seconds_bucket{le="0.05",method="GET",path_template="/number"} 1.0
starlette_requests_processing_time_seconds_bucket{le="0.075",method="GET",path_template="/number"} 1.0
starlette_requests_processing_time_seconds_bucket{le="0.1",method="GET",path_template="/number"} 1.0
starlette_requests_processing_time_seconds_bucket{le="0.25",method="GET",path_template="/number"} 1.0
starlette_requests_processing_time_seconds_bucket{le="0.5",method="GET",path_template="/number"} 1.0
starlette_requests_processing_time_seconds_bucket{le="0.75",method="GET",path_template="/number"} 1.0
starlette_requests_processing_time_seconds_bucket{le="1.0",method="GET",path_template="/number"} 1.0
starlette_requests_processing_time_seconds_bucket{le="2.5",method="GET",path_template="/number"} 1.0
starlette_requests_processing_time_seconds_bucket{le="5.0",method="GET",path_template="/number"} 1.0
starlette_requests_processing_time_seconds_bucket{le="7.5",method="GET",path_template="/number"} 1.0
starlette_requests_processing_time_seconds_bucket{le="10.0",method="GET",path_template="/number"} 1.0
starlette_requests_processing_time_seconds_bucket{le="+Inf",method="GET",path_template="/number"} 1.0
starlette_requests_processing_time_seconds_count{method="GET",path_template="/number"} 1.0
starlette_requests_processing_time_seconds_sum{method="GET",path_template="/number"} 0.0014887330000021848
# HELP starlette_requests_processing_time_seconds_created Histogram of requests processing time by path (in seconds)
# TYPE starlette_requests_processing_time_seconds_created gauge
starlette_requests_processing_time_seconds_created{method="GET",path_template="/"} 1.659442850482569e+09
starlette_requests_processing_time_seconds_created{method="GET",path_template="/random"} 1.659442855023223e+09
starlette_requests_processing_time_seconds_created{method="GET",path_template="/number"} 1.6594428614245682e+09
# HELP starlette_exceptions_total Total count of exceptions raised by path and exception type
# TYPE starlette_exceptions_total counter
# HELP starlette_requests_in_progress Gauge of requests by method and path currently being processed
# TYPE starlette_requests_in_progress gauge
starlette_requests_in_progress{method="GET",path_template="/"} 0.0
starlette_requests_in_progress{method="GET",path_template="/random"} 0.0
starlette_requests_in_progress{method="GET",path_template="/number"} 0.0
starlette_requests_in_progress{method="GET",path_template="/metrics"} 1.0
```

Or you can use swagger UI via broser:
`http://127.0.0.1:8000/docs`


### Building the application - Docker

Locking version
```
pip3 freeze > requirements.txt
```

Building
```
docker build -t myapp .
```

Running
```
docker run -d --name mycontainer -p 80:80 myapp
```


## Running k8
- Create kind cluster
```
kind create cluster --image kindest/node:v1.24.2 --config - <<EOF
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
kubeadmConfigPatches:
- |-
  kind: ClusterConfiguration
  # configure controller-manager bind address
  controllerManager:
    extraArgs:
      bind-address: 0.0.0.0
  # configure etcd metrics listen address
  etcd:
    local:
      extraArgs:
        listen-metrics-urls: http://0.0.0.0:2381
  # configure scheduler bind address
  scheduler:
    extraArgs:
      bind-address: 0.0.0.0
- |-
  kind: KubeProxyConfiguration
  # configure proxy metrics bind address
  metricsBindAddress: 0.0.0.0
nodes:
  - role: control-plane
  - role: control-plane
  - role: control-plane
  - role: worker
  - role: worker
  - role: worker
  - role: worker
  - role: worker
EOF
```

- Check if the cluster is up and running
```
kubectl cluster-info --context kind-observ-lab
kubectl get nodes
kubectl get pods -A
```

## Provisioning observ tools

### Prometheus

```
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
```

```
helm upgrade --install \
  --namespace monitoring --create-namespace \
  --repo https://prometheus-community.github.io/helm-charts \
  -f helm/kube-prometheus/values.yaml \
  kube-prometheus-stack kube-prometheus-stack 
```

### Loki

```
helm install loki grafana/loki-simple-scalable -n loki --create-namespace -f helm/loki/values.yaml
```

### Promtail

```
helm install promtail grafana/promtail -n loki -f helm/promtail/values.yaml
```

### Tempo

```
helm install tempo grafana/tempo-distributed -n tempo --create-namespace -f helm/tempo/values.yaml
```

### Grafana decode

```
➜echo 'cHJvbS1vcGVyYXRvcg==' | base64 -d
prom-operator
(⎈ |kind-kind:monitoring)
18:04:37 in microservices-demo/deploy/kubernetes on  master [!?] on 🐳 v20.10.12
➜echo 'YWRtaW4=' | base64 -d
admin
```

### Synthetic-load-generator

```
k apply -f helm/syntetic-microservice/deploy.yaml
```