provider "kubernetes" {

  host                   = yamldecode(var.k8s_config_raw).clusters[0].cluster.server
  client_certificate     = base64decode(yamldecode(var.k8s_config_raw).users[0].user["client-certificate-data"])
  client_key             = base64decode(yamldecode(var.k8s_config_raw).users[0].user["client-key-data"])
  cluster_ca_certificate = base64decode(yamldecode(var.k8s_config_raw).clusters[0].cluster["certificate-authority-data"])

}

resource "kubernetes_namespace_v1" "web" {
  metadata {
    name = "profos-web"
  }
}

resource "kubernetes_manifest" "nginx_deployment" {
  manifest = {
    apiVersion = "apps/v1"
    kind       = "Deployment"
    metadata = {
      name      = "profos-web-server"
      namespace = kubernetes_namespace_v1.web.metadata[0].name
    }
    spec = {
      replicas = 2
      selector = { matchLabels = { app = "profos-web" } }
      template = {
        metadata = { labels = { app = "profos-web" } }
        spec = {
          containers = [{
            name  = "profos-web"
            image = "xvwall/profos-web:latest"
            ports = [{ containerPort = 80 }]
            resources = {
              requests = { cpu = "100m", memory = "128Mi" }
              limits   = { cpu = "500m", memory = "256Mi" }
            }
          }]
        }
      }
    }
  }
}

resource "kubernetes_manifest" "nginx_service" {
  manifest = {
    apiVersion = "v1"
    kind       = "Service"
    metadata = {
      name      = "profos-web-service"
      namespace = kubernetes_namespace_v1.web.metadata[0].name
    }
    spec = {
      type = "LoadBalancer"
      selector = { app = "profos-web" }
      ports = [{
        port        = 80
        targetPort  = 80
      }]
    }
  }
}
