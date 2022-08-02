data "template_file" "loki" {
  template = file("${path.module}/templates/loki.tpl")
}

data "template_file" "promtail" {
  template = file("${path.module}/templates/promtail.tpl")
}

data "template_file" "tempo" {
  template = file("${path.module}/templates/tempo.tpl")
}

data "template_file" "prometheus" {
  template = file("${path.module}/templates/prometheus.tpl")
}
