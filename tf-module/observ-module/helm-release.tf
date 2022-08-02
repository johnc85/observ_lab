resource "helm_release" "loki" {
  count            = var.enable_loki
  name             = "loki-simple-scalable"
  repository       = "https://grafana.github.io/helm-charts"
  chart            = "loki-simple-scalable"
  version          = var.loki_tag
  create_namespace = true
  namespace        = "loki"
  wait             = true
  values           = [data.template_file.loki.rendered]
}

resource "helm_release" "promtail" {
  count            = var.enable_promtail
  name             = "promtail"
  repository       = "https://grafana.github.io/helm-charts"
  chart            = "promtail"
  version          = var.promtail_tag
  create_namespace = true
  namespace        = "loki"
  wait             = true
  values           = [data.template_file.promtail.rendered]
  depends_on       = [helm_release.loki]
}

resource "helm_release" "tempo" {
  count            = var.enable_tempo
  name             = "tempo"
  repository       = "https://grafana.github.io/helm-charts"
  chart            = "tempo-distributed"
  version          = var.tempo_tag
  create_namespace = true
  namespace        = "tempo"
  wait             = true
  timeout          = 600
  values           = [data.template_file.tempo.rendered]
  depends_on       = [helm_release.promtail]
}

resource "helm_release" "prometheus" {
  count            = var.enable_kube_prometheus_stack
  name             = "kube-prometheus-stack"
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "kube-prometheus-stack"
  version          = var.kube_prometheus_stack_tag
  create_namespace = true
  namespace        = "monitoring"
  wait             = true
  values           = [data.template_file.prometheus.rendered]
  depends_on       = [helm_release.tempo]
}

resource "helm_release" "myapp" {
  count            = var.enable_myapp
  name             = "myapp"
  repository       = "${path.module}/helm/"
  chart            = "myapp"
  version          = var.myapp_tag
  create_namespace = true
  namespace        = "myapp"
  wait             = true
  depends_on       = [helm_release.prometheus]
}
