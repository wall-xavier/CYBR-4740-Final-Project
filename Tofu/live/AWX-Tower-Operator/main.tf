provider "helm" {

  kubernetes = {
    host                   = yamldecode(var.k8s_config_raw).clusters[0].cluster.server
    client_certificate     = base64decode(yamldecode(var.k8s_config_raw).users[0].user["client-certificate-data"])
    client_key             = base64decode(yamldecode(var.k8s_config_raw).users[0].user["client-key-data"])
    cluster_ca_certificate = base64decode(yamldecode(var.k8s_config_raw).clusters[0].cluster["certificate-authority-data"])
  }
}

provider "kubernetes" {

  host                   = yamldecode(var.k8s_config_raw).clusters[0].cluster.server
  client_certificate     = base64decode(yamldecode(var.k8s_config_raw).users[0].user["client-certificate-data"])
  client_key             = base64decode(yamldecode(var.k8s_config_raw).users[0].user["client-key-data"])
  cluster_ca_certificate = base64decode(yamldecode(var.k8s_config_raw).clusters[0].cluster["certificate-authority-data"])

}

resource "helm_release" "awx_operator" {
  name       = "awx-operator"
  repository = "https://ansible-community.github.io/awx-operator-helm/"
  chart      = "awx-operator"
  namespace  = "awx"
  wait       = true

  set = [
    {
      name  = "create_namespace"
      value = "false"
    },
    {
      name  = "AWX.enabled"
      value = "true"
    },
    {
      name  = "AWX.name"
      value = "awx-profos"
    },
    {
      name  = "AWX.spec.postgres_storage_class"
      value = "vsphere-csi-sc"
    },
    {
      name  = "AWX.spec.service_type"
      value = "NodePort"
    },
    {
      name  = "control_plane_ee_image_pull_auth"
      value = ""
    },
    {
      name  = "AWX.spec.postgres_pod_settings.securityContext.runAsUser"
      value = "26"
    },
    {
      name  = "AWX.spec.postgres_pod_settings.securityContext.fsGroup"
      value = "26"
    },
    {
      name  = "AWX.spec.postgres_init_container_resource_requirements.requests.cpu"
      value = "50m"
    },
    {
      name  = "AWX.spec.postgres_init_container_resource_requirements.requests.memory"
      value = "128Mi"
    },
    {
      name  = "AWX.spec.postgres_data_volume_init"
      value = "true"
    },
    {
      name  = "AWX.spec.postgres_init_container_commands"
      value = "chown -R 26:26 /var/lib/pgsql/data && chmod -R 700 /var/lib/pgsql/data"
    }
  ]
}
