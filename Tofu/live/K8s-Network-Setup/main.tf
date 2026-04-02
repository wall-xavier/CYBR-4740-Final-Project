provider "helm" {

  kubernetes = {
    host                  = yamldecode(var.k8s_config_raw).clusters[0].cluster.server
    client_certificate    = base64decode(yamldecode(var.k8s_config_raw).users[0].user["client-certificate-data"])
    client_key            = base64decode(yamldecode(var.k8s_config_raw).users[0].user["client-key-data"])
    cluser_ca_certificate = base64decode(yamldecode(var.k8s_config_raw).clusters[0].cluster["certificate-authority-data"])
    insecure = true
  }
}

resource "helm_release" "flannel" {

  name             = "flannel"
  repository       = "https://flannel-io.github.io/flannel/"
  chart            = "flannel"
  namespace        = "kube-flannel"
  create_namespace = true


  set = [

    {

      name  = "podCidr"
      value = "10.244.0.0/16"

    },
    {

      name  = "extraArgs"
      value = "{--iface=ens160}"

    }

  ]

}
