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

resource "kubernetes_secret_v1" "cpi_global_secret" {
  metadata {
    name      = "cpi-global-secret"
    namespace = "kube-system"
  }

  data = {
    "${var.vsphere_server}.username" = var.vsphere_user
    "${var.vsphere_server}.password" = var.vsphere_password
  }

  type = "Opaque"
}

resource "kubernetes_config_map_v1" "cloud_config" {
  metadata {
    name      = "cloud-config"
    namespace = "kube-system"
  }

  data = {
    "vsphere.conf" = <<EOF
[Global]
port = "443"
insecure-flag = "true"
secret-name = "cpi-global-secret"
secret-namespace = "kube-system"
cluster-id = "profos-k8s-cluster"

[VirtualCenter "${var.vsphere_server}"]
datacenters = "${var.vsphere_datacenter}"

EOF
  }
}

resource "kubernetes_secret_v1" "vsphere_csi_config" {
  metadata {
    name      = "vsphere-csi-config"
    namespace = "kube-system"
  }

  type = "Opaque"

  data = {
    "csi-vsphere.conf" = <<EOF
[Global]
cluster-id = "profos-k8s-cluster"
insecure-flag = "true"

[VirtualCenter "${var.vsphere_server}"]
user = "${var.vsphere_user}"
password = "${var.vsphere_password}"
datacenters = "${var.vsphere_datacenter}"
EOF
  }
}

resource "helm_release" "vsphere_cpi" {
  name       = "vsphere-cpi"
  repository = "https://kubernetes.github.io/cloud-provider-vsphere"
  chart      = "vsphere-cpi"
  namespace  = "kube-system"

  depends_on = [
    kubernetes_secret_v1.cpi_global_secret,
    kubernetes_config_map_v1.cloud_config
  ]

  set = [
    {
      name  = "config.enabled"
      value = "false"
    },
    {
      name  = "config.secretName"
      value = "cpi-global-secret"
    },
    {
      name  = "config.configmapName"
      value = "cloud-config"
    }
  ]
}

resource "helm_release" "vsphere_csi" {
  name       = "vsphere-csi"
  repository = "https://vsphere-tmm.github.io/helm-charts"
  chart      = "vsphere-csi"
  namespace  = "kube-system"

  depends_on = [
    helm_release.vsphere_cpi,
    kubernetes_secret_v1.vsphere_csi_config
  ]

  set = [
    {
      name  = "global.config.csidriver.enabled"
      value = "true"
    },
    {
      name  = "global.config.existingSecret"
      value = "vsphere-csi-config"
    },
    {
      name  = "node.registrar.image.tag"
      value = "v2.5.1"
    },
    {
      name  = "node.livenessprobe.image.tag"
      value = "v2.12.0"
    },
    {
      name  = "controller.provisioner.image.tag"
      value = "v4.0.1"
    },
    {
      name  = "controller.attacher.image.tag"
      value = "v4.5.1"
    },
    {
      name  = "controller.resizer.image.tag"
      value = "v1.10.1"
    },
    {
      name  = "controller.livenessprobe.image.tag"
      value = "v2.12.0"
    }
  ]
}
