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

resource "kubernetes_namespace_v1" "awx" {
  metadata {
    name = "awx"
  }
}

resource "kubernetes_secret_v1" "vsphere_csi_config" {
  metadata {
    name      = "vsphere-csi-config"
    namespace = kubernetes_namespace_v1.awx.metadata[0].name
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
