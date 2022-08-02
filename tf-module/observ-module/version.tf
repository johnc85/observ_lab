terraform {
  required_version = ">=1.0"
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "2.4.1"
    }


    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.11.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "1.14.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "3.1.1"
    }
    template = {
      source  = "hashicorp/template"
      version = "2.2.0"
    }
  }
}

provider "helm" {
  kubernetes {
    config_path = pathexpand(var.cluster_config_path)
  }
}
