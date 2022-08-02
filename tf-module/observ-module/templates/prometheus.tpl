grafana:
  enabled: true
  namespaceOverride: ""

  ## ForceDeployDatasources Create datasource configmap even if grafana deployment has been disabled
  ##
  forceDeployDatasources: false

  ## ForceDeployDashboard Create dashboard configmap even if grafana deployment has been disabled
  ##
  forceDeployDashboards: false

  ## Deploy default dashboards
  ##
  defaultDashboardsEnabled: true

  ## Timezone for the default dashboards
  ## Other options are: browser or a specific timezone, i.e. Europe/Luxembourg
  ##
  defaultDashboardsTimezone: utc

  adminPassword: prom-operator

  rbac:
    ## If true, Grafana PSPs will be created
    ##
    pspEnabled: false

  ingress:
    ## If true, Grafana Ingress will be created
    ##
    enabled: false

    ## IngressClassName for Grafana Ingress.
    ## Should be provided if Ingress is enable.
    ##
    # ingressClassName: nginx

    ## Annotations for Grafana Ingress
    ##
    annotations:
      {}
      # kubernetes.io/ingress.class: nginx
      # kubernetes.io/tls-acme: "true"

    ## Labels to be added to the Ingress
    ##
    labels: {}

    ## Hostnames.
    ## Must be provided if Ingress is enable.
    ##
    # hosts:
    #   - grafana.domain.com
    hosts: []

    ## Path for grafana ingress
    path: /

    ## TLS configuration for grafana Ingress
    ## Secret must be manually created in the namespace
    ##
    tls: []
    # - secretName: grafana-general-tls
    #   hosts:
    #   - grafana.example.com

  sidecar:
    dashboards:
      enabled: true
      label: grafana_dashboard
      labelValue: "1"

      ## Annotations for Grafana dashboard configmaps
      ##
      annotations: {}
      multicluster:
        global:
          enabled: false
        etcd:
          enabled: false
      provider:
        allowUiUpdates: false
    datasources:
      enabled: true
      defaultDatasourceEnabled: true

      uid: prometheus

      ## URL of prometheus datasource
      ##
      # url: http://prometheus-stack-prometheus:9090/

      # If not defined, will use prometheus.prometheusSpec.scrapeInterval or its default
      # defaultDatasourceScrapeInterval: 15s

      ## Annotations for Grafana datasource configmaps
      ##
      annotations: {}

      ## Create datasource for each Pod of Prometheus StatefulSet;
      ## this uses headless service `prometheus-operated` which is
      ## created by Prometheus Operator
      ## ref: https://github.com/prometheus-operator/prometheus-operator/blob/0fee93e12dc7c2ea1218f19ae25ec6b893460590/pkg/prometheus/statefulset.go#L255-L286
      createPrometheusReplicasDatasources: false
      label: grafana_datasource
      labelValue: "1"

      ## Field with internal link pointing to existing data source in Grafana.
      ## Can be provisioned via additionalDataSources
      exemplarTraceIdDestinations:
        {}
        # datasourceUid: Jaeger
        # traceIdLabelName: trace_id

  extraConfigmapMounts: []
  # - name: certs-configmap
  #   mountPath: /etc/grafana/ssl/
  #   configMap: certs-configmap
  #   readOnly: true

  deleteDatasources: []
  # - name: example-datasource
  #   orgId: 1

  ## Configure additional grafana datasources (passed through tpl)
  ## ref: http://docs.grafana.org/administration/provisioning/#datasources
  additionalDataSources:
    - name: Loki
      type: loki
      access: proxy
      url: http://loki-gateway.loki.svc
      basicAuth: false
      jsonData:
        tlsSkipVerify: true
        maxLines: 1000
        derivedFields:
          - datasourceUid: Tempo
            matcherRegex: "[t|T][R|r][A|a][C|c][E|e][i|I][d|D][:|=|\\s](\\w+)"
            name: TraceId
            url: "$${__value.raw}"

    - name: Tempo
      type: tempo
      # Access mode - proxy (server in the UI) or direct (browser in the UI).
      access: proxy
      url: http://tempo-tempo-distributed-query-frontend.tempo.svc:3100
      jsonData:
        tlsSkipVerify: true
        httpMethod: GET
        tracesToLogs:
          datasourceUid: Loki
          tags: ["job", "instance", "pod", "namespace"]
          mappedTags: [{ key: "service.name", value: "service" }]
          mapTagNamesEnabled: true
          spanStartTimeShift: "1h"
          spanEndTimeShift: "1h"
          filterByTraceID: true
          filterBySpanID: true
        # serviceMap:
        #   datasourceUid: 'prometheus'
        search:
          hide: false
        nodeGraph:
          enabled: true
        lokiSearch:
          datasourceUid: "Loki"

  ## Passed to grafana subchart and used by servicemonitor below
  ##
  service:
    portName: http-web

  serviceMonitor:
    # If true, a ServiceMonitor CRD is created for a prometheus operator
    # https://github.com/coreos/prometheus-operator
    #
    enabled: true

    # Path to use for scraping metrics. Might be different if server.root_url is set
    # in grafana.ini
    path: "/metrics"

    #  namespace: monitoring  (defaults to use the namespace this chart is deployed to)

    # labels for the ServiceMonitor
    labels: {}

    # Scrape interval. If not set, the Prometheus default scrape interval is used.
    #
    interval: ""
    scheme: http
    tlsConfig: {}
    scrapeTimeout: 30s

    ## RelabelConfigs to apply to samples before scraping
    ## ref: https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/api.md#relabelconfig
    ##
    relabelings: []
    # - sourceLabels: [__meta_kubernetes_pod_node_name]
    #   separator: ;
    #   regex: ^(.*)$
    #   targetLabel: nodename
    #   replacement: $1
    #   action: replace

## Component scraping the kube api server
##
kubeApiServer:
  enabled: true
  tlsConfig:
    serverName: kubernetes
    insecureSkipVerify: false
  serviceMonitor:
    ## Scrape interval. If not set, the Prometheus default scrape interval is used.
    ##
    interval: ""
    ## proxyUrl: URL of a proxy that should be used for scraping.
    ##
    proxyUrl: ""

    jobLabel: component
    selector:
      matchLabels:
        component: apiserver
        provider: kubernetes

    ## MetricRelabelConfigs to apply to samples after scraping, but before ingestion.
    ## ref: https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/api.md#relabelconfig
    ##
    metricRelabelings:
      # Drop excessively noisy apiserver buckets.
      - action: drop
        regex: apiserver_request_duration_seconds_bucket;(0.15|0.2|0.3|0.35|0.4|0.45|0.6|0.7|0.8|0.9|1.25|1.5|1.75|2|3|3.5|4|4.5|6|7|8|9|15|25|40|50)
        sourceLabels:
          - __name__
          - le
    # - action: keep
    #   regex: 'kube_(daemonset|deployment|pod|namespace|node|statefulset).+'
    #   sourceLabels: [__name__]

    ## RelabelConfigs to apply to samples before scraping
    ## ref: https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/api.md#relabelconfig
    ##
    relabelings: []
    # - sourceLabels:
    #     - __meta_kubernetes_namespace
    #     - __meta_kubernetes_service_name
    #     - __meta_kubernetes_endpoint_port_name
    #   action: keep
    #   regex: default;kubernetes;https
    # - targetLabel: __address__
    #   replacement: kubernetes.default.svc:443

    ## Additional labels
    ##
    additionalLabels: {}
    #  foo: bar

## Component scraping the kubelet and kubelet-hosted cAdvisor
##
kubelet:
  enabled: true
  namespace: kube-system

  serviceMonitor:
    ## Scrape interval. If not set, the Prometheus default scrape interval is used.
    ##
    interval: ""

    ## proxyUrl: URL of a proxy that should be used for scraping.
    ##
    proxyUrl: ""

    ## Enable scraping the kubelet over https. For requirements to enable this see
    ## https://github.com/prometheus-operator/prometheus-operator/issues/926
    ##
    https: true

    ## Enable scraping /metrics/cadvisor from kubelet's service
    ##
    cAdvisor: true

    ## Enable scraping /metrics/probes from kubelet's service
    ##
    probes: true

    ## Enable scraping /metrics/resource from kubelet's service
    ## This is disabled by default because container metrics are already exposed by cAdvisor
    ##
    resource: false
    # From kubernetes 1.18, /metrics/resource/v1alpha1 renamed to /metrics/resource
    resourcePath: "/metrics/resource/v1alpha1"

    ## MetricRelabelConfigs to apply to samples after scraping, but before ingestion.
    ## ref: https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/api.md#relabelconfig
    ##
    cAdvisorMetricRelabelings:
      # Drop less useful container CPU metrics.
      - sourceLabels: [__name__]
        action: drop
        regex: "container_cpu_(cfs_throttled_seconds_total|load_average_10s|system_seconds_total|user_seconds_total)"
      # Drop less useful container / always zero filesystem metrics.
      - sourceLabels: [__name__]
        action: drop
        regex: "container_fs_(io_current|io_time_seconds_total|io_time_weighted_seconds_total|reads_merged_total|sector_reads_total|sector_writes_total|writes_merged_total)"
      # Drop less useful / always zero container memory metrics.
      - sourceLabels: [__name__]
        action: drop
        regex: "container_memory_(mapped_file|swap)"
      # Drop less useful container process metrics.
      - sourceLabels: [__name__]
        action: drop
        regex: "container_(file_descriptors|tasks_state|threads_max)"
      # Drop container spec metrics that overlap with kube-state-metrics.
      - sourceLabels: [__name__]
        action: drop
        regex: "container_spec.*"
      # Drop cgroup metrics with no pod.
      - sourceLabels: [id, pod]
        action: drop
        regex: ".+;"
    # - sourceLabels: [__name__, image]
    #   separator: ;
    #   regex: container_([a-z_]+);
    #   replacement: $1
    #   action: drop
    # - sourceLabels: [__name__]
    #   separator: ;
    #   regex: container_(network_tcp_usage_total|network_udp_usage_total|tasks_state|cpu_load_average_10s)
    #   replacement: $1
    #   action: drop

    ## MetricRelabelConfigs to apply to samples after scraping, but before ingestion.
    ## ref: https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/api.md#relabelconfig
    ##
    probesMetricRelabelings: []
    # - sourceLabels: [__name__, image]
    #   separator: ;
    #   regex: container_([a-z_]+);
    #   replacement: $1
    #   action: drop
    # - sourceLabels: [__name__]
    #   separator: ;
    #   regex: container_(network_tcp_usage_total|network_udp_usage_total|tasks_state|cpu_load_average_10s)
    #   replacement: $1
    #   action: drop

    ## RelabelConfigs to apply to samples before scraping
    ## ref: https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/api.md#relabelconfig
    ##
    ## metrics_path is required to match upstream rules and charts
    cAdvisorRelabelings:
      - sourceLabels: [__metrics_path__]
        targetLabel: metrics_path
    # - sourceLabels: [__meta_kubernetes_pod_node_name]
    #   separator: ;
    #   regex: ^(.*)$
    #   targetLabel: nodename
    #   replacement: $1
    #   action: replace

    ## RelabelConfigs to apply to samples before scraping
    ## ref: https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/api.md#relabelconfig
    ##
    probesRelabelings:
      - sourceLabels: [__metrics_path__]
        targetLabel: metrics_path
    # - sourceLabels: [__meta_kubernetes_pod_node_name]
    #   separator: ;
    #   regex: ^(.*)$
    #   targetLabel: nodename
    #   replacement: $1
    #   action: replace

    ## RelabelConfigs to apply to samples before scraping
    ## ref: https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/api.md#relabelconfig
    ##
    resourceRelabelings:
      - sourceLabels: [__metrics_path__]
        targetLabel: metrics_path
    # - sourceLabels: [__meta_kubernetes_pod_node_name]
    #   separator: ;
    #   regex: ^(.*)$
    #   targetLabel: nodename
    #   replacement: $1
    #   action: replace

    ## MetricRelabelConfigs to apply to samples after scraping, but before ingestion.
    ## ref: https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/api.md#relabelconfig
    ##
    metricRelabelings: []
    # - sourceLabels: [__name__, image]
    #   separator: ;
    #   regex: container_([a-z_]+);
    #   replacement: $1
    #   action: drop
    # - sourceLabels: [__name__]
    #   separator: ;
    #   regex: container_(network_tcp_usage_total|network_udp_usage_total|tasks_state|cpu_load_average_10s)
    #   replacement: $1
    #   action: drop

    ## RelabelConfigs to apply to samples before scraping
    ## ref: https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/api.md#relabelconfig
    ##
    ## metrics_path is required to match upstream rules and charts
    relabelings:
      - sourceLabels: [__metrics_path__]
        targetLabel: metrics_path
    # - sourceLabels: [__meta_kubernetes_pod_node_name]
    #   separator: ;
    #   regex: ^(.*)$
    #   targetLabel: nodename
    #   replacement: $1
    #   action: replace

    ## Additional labels
    ##
    additionalLabels: {}
    #  foo: bar

## Component scraping the kube controller manager
##
kubeControllerManager:
  enabled: true

  ## If your kube controller manager is not deployed as a pod, specify IPs it can be found on
  ##
  endpoints: []
  # - 10.141.4.22
  # - 10.141.4.23
  # - 10.141.4.24

  ## If using kubeControllerManager.endpoints only the port and targetPort are used
  ##
  service:
    enabled: true
    ## If null or unset, the value is determined dynamically based on target Kubernetes version due to change
    ## of default port in Kubernetes 1.22.
    ##
    port: null
    targetPort: null
    # selector:
    #   component: kube-controller-manager

  serviceMonitor:
    enabled: true
    ## Scrape interval. If not set, the Prometheus default scrape interval is used.
    ##
    interval: ""

    ## proxyUrl: URL of a proxy that should be used for scraping.
    ##
    proxyUrl: ""

    ## Enable scraping kube-controller-manager over https.
    ## Requires proper certs (not self-signed) and delegated authentication/authorization checks.
    ## If null or unset, the value is determined dynamically based on target Kubernetes version.
    ##
    https: null

    # Skip TLS certificate validation when scraping
    insecureSkipVerify: null

    # Name of the server to use when validating TLS certificate
    serverName: null

    ## MetricRelabelConfigs to apply to samples after scraping, but before ingestion.
    ## ref: https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/api.md#relabelconfig
    ##
    metricRelabelings: []
    # - action: keep
    #   regex: 'kube_(daemonset|deployment|pod|namespace|node|statefulset).+'
    #   sourceLabels: [__name__]

    ## RelabelConfigs to apply to samples before scraping
    ## ref: https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/api.md#relabelconfig
    ##
    relabelings: []
    # - sourceLabels: [__meta_kubernetes_pod_node_name]
    #   separator: ;
    #   regex: ^(.*)$
    #   targetLabel: nodename
    #   replacement: $1
    #   action: replace

    ## Additional labels
    ##
    additionalLabels: {}
    #  foo: bar

## Component scraping coreDns. Use either this or kubeDns
##
coreDns:
  enabled: true
  service:
    port: 9153
    targetPort: 9153
    # selector:
    #   k8s-app: kube-dns
  serviceMonitor:
    ## Scrape interval. If not set, the Prometheus default scrape interval is used.
    ##
    interval: ""

    ## proxyUrl: URL of a proxy that should be used for scraping.
    ##
    proxyUrl: ""

    ## MetricRelabelConfigs to apply to samples after scraping, but before ingestion.
    ## ref: https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/api.md#relabelconfig
    ##
    metricRelabelings: []
    # - action: keep
    #   regex: 'kube_(daemonset|deployment|pod|namespace|node|statefulset).+'
    #   sourceLabels: [__name__]

    ## RelabelConfigs to apply to samples before scraping
    ## ref: https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/api.md#relabelconfig
    ##
    relabelings: []
    # - sourceLabels: [__meta_kubernetes_pod_node_name]
    #   separator: ;
    #   regex: ^(.*)$
    #   targetLabel: nodename
    #   replacement: $1
    #   action: replace

    ## Additional labels
    ##
    additionalLabels: {}
    #  foo: bar

## Component scraping kubeDns. Use either this or coreDns
##
kubeDns:
  enabled: false
  service:
    dnsmasq:
      port: 10054
      targetPort: 10054
    skydns:
      port: 10055
      targetPort: 10055
    # selector:
    #   k8s-app: kube-dns
  serviceMonitor:
    ## Scrape interval. If not set, the Prometheus default scrape interval is used.
    ##
    interval: ""

    ## proxyUrl: URL of a proxy that should be used for scraping.
    ##
    proxyUrl: ""

    ## MetricRelabelConfigs to apply to samples after scraping, but before ingestion.
    ## ref: https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/api.md#relabelconfig
    ##
    metricRelabelings: []
    # - action: keep
    #   regex: 'kube_(daemonset|deployment|pod|namespace|node|statefulset).+'
    #   sourceLabels: [__name__]

    ## RelabelConfigs to apply to samples before scraping
    ## ref: https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/api.md#relabelconfig
    ##
    relabelings: []
    # - sourceLabels: [__meta_kubernetes_pod_node_name]
    #   separator: ;
    #   regex: ^(.*)$
    #   targetLabel: nodename
    #   replacement: $1
    #   action: replace

    ## MetricRelabelConfigs to apply to samples after scraping, but before ingestion.
    ## ref: https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/api.md#relabelconfig
    ##
    dnsmasqMetricRelabelings: []
    # - action: keep
    #   regex: 'kube_(daemonset|deployment|pod|namespace|node|statefulset).+'
    #   sourceLabels: [__name__]

    ## RelabelConfigs to apply to samples before scraping
    ## ref: https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/api.md#relabelconfig
    ##
    dnsmasqRelabelings: []
    # - sourceLabels: [__meta_kubernetes_pod_node_name]
    #   separator: ;
    #   regex: ^(.*)$
    #   targetLabel: nodename
    #   replacement: $1
    #   action: replace

    ## Additional labels
    ##
    additionalLabels: {}
    #  foo: bar

## Component scraping etcd
##
kubeEtcd:
  enabled: true

  ## If your etcd is not deployed as a pod, specify IPs it can be found on
  ##
  endpoints: []
  # - 10.141.4.22
  # - 10.141.4.23
  # - 10.141.4.24

  ## Etcd service. If using kubeEtcd.endpoints only the port and targetPort are used
  ##
  service:
    enabled: true
    port: 2379
    targetPort: 2381
    # selector:
    #   component: etcd

  ## Configure secure access to the etcd cluster by loading a secret into prometheus and
  ## specifying security configuration below. For example, with a secret named etcd-client-cert
  ##
  ## serviceMonitor:
  ##   scheme: https
  ##   insecureSkipVerify: false
  ##   serverName: localhost
  ##   caFile: /etc/prometheus/secrets/etcd-client-cert/etcd-ca
  ##   certFile: /etc/prometheus/secrets/etcd-client-cert/etcd-client
  ##   keyFile: /etc/prometheus/secrets/etcd-client-cert/etcd-client-key
  ##
  serviceMonitor:
    enabled: true
    ## Scrape interval. If not set, the Prometheus default scrape interval is used.
    ##
    interval: ""
    ## proxyUrl: URL of a proxy that should be used for scraping.
    ##
    proxyUrl: ""
    scheme: http
    insecureSkipVerify: false
    serverName: ""
    caFile: ""
    certFile: ""
    keyFile: ""

    ## MetricRelabelConfigs to apply to samples after scraping, but before ingestion.
    ## ref: https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/api.md#relabelconfig
    ##
    metricRelabelings: []
    # - action: keep
    #   regex: 'kube_(daemonset|deployment|pod|namespace|node|statefulset).+'
    #   sourceLabels: [__name__]

    ## RelabelConfigs to apply to samples before scraping
    ## ref: https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/api.md#relabelconfig
    ##
    relabelings: []
    # - sourceLabels: [__meta_kubernetes_pod_node_name]
    #   separator: ;
    #   regex: ^(.*)$
    #   targetLabel: nodename
    #   replacement: $1
    #   action: replace

    ## Additional labels
    ##
    additionalLabels: {}
    #  foo: bar