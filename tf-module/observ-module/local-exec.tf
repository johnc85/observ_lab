resource "null_resource" "exec-cm-grafana" {
  provisioner "local-exec" {
    command = <<EOF
    kubectl apply -f manifests/cm-grafana.yaml
EOF
  }
  depends_on = [helm_release.prometheus]
}

