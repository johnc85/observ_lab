data "kubectl_path_documents" "syntetic" {
  pattern = "${path.module}/manifests/syntetic-monitor.yaml"
}

resource "kubectl_manifest" "syntetic" {
  count            = length(data.kubectl_path_documents.syntetic.documents)
  yaml_body        = element(data.kubectl_path_documents.syntetic.documents, count.index)
  wait_for_rollout = false
  force_new        = false

  depends_on = [helm_release.myapp]
}
