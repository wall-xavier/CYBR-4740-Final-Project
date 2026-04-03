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

resource "helm_release" "vsphere_cpi" {

  name       = "vsphere-cpi"
  repository = "https://kubernetes.github.io/cloud-provider-vsphere"
  chart      = "vsphere-cpi"
  namespace  = "kube-system"
  set = [{

    name  = "config.vcenter"
    value = var.vsphere_server

    },

    {
      name  = "config.username"
      value = var.vsphere_user
    },

    {
      name  = "config.password"
      value = var.vsphere_password
    },

    {
      name  = "config.datacenter"
      value = var.vsphere_datacenter
    }
  ]
}

resource "helm_release" "vsphere_csi" {

  name       = "vsphere-csi"
  repository = "https://vsphere-tmm.github.io/helm-charts"
  chart      = "vsphere-csi"
  namespace  = "kube-system"

  depends_on = [helm_release.vsphere_cpi]

  set = [{

    name  = "vcenter.host"
    value = var.vsphere_server

    },

    {
      name  = "vcenter.username"
      value = var.vsphere_user
    },

    {
      name  = "vcenter.password"
      value = var.vsphere_password
    },

    {
      name  = "vcenter.datacenter"
      value = var.vsphere_datacenter
    }

  ]

}
