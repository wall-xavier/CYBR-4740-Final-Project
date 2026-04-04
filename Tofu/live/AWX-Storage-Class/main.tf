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

resource "kubernetes_storage_class_v1" "vsphere_csi_sc" {

  metadata {
    name = "vsphere-csi-sc"
  }


  storage_provisioner = "csi.vsphere.vmware.com"
  reclaim_policy      = "Delete"
  volume_binding_mode = "Immediate"

  parameters = {

     storagepolicyname = "K8s Datastore Policy"
  }
}
