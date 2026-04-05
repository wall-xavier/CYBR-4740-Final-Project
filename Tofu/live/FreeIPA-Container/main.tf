provider "kubernetes" {

  host                   = yamldecode(var.k8s_config_raw).clusters[0].cluster.server
  client_certificate     = base64decode(yamldecode(var.k8s_config_raw).users[0].user["client-certificate-data"])
  client_key             = base64decode(yamldecode(var.k8s_config_raw).users[0].user["client-key-data"])
  cluster_ca_certificate = base64decode(yamldecode(var.k8s_config_raw).clusters[0].cluster["certificate-authority-data"])

}

resource "kubernetes_namespace_v1" "freeipa" {
  metadata {
    name = "freeipa"
  }
}

resource "kubernetes_manifest" "freeipa_pvc" {
  manifest = {
    apiVersion = "v1"
    kind       = "PersistentVolumeClaim"
    metadata = {
      name      = "freeipa-data-pvc"
      namespace = kubernetes_namespace_v1.freeipa.metadata[0].name
    }
    spec = {
      accessModes      = ["ReadWriteOnce"]
      storageClassName = "vsphere-csi-sc"
      resources = {
        requests = {
          storage = "10Gi"
        }
      }
    }
  }
}
resource "kubernetes_manifest" "freeipa_deployment" {
  depends_on = [kubernetes_manifest.freeipa_pvc]

  manifest = {
    apiVersion = "apps/v1"
    kind       = "Deployment"
    metadata = {
      name      = "freeipa-server"
      namespace = kubernetes_namespace_v1.freeipa.metadata[0].name
    }
    spec = {
      replicas = 1
      selector = { matchLabels = { app = "freeipa" } }
      template = {
        metadata = { labels = { app = "freeipa" } }
        spec = {
          
          dnsPolicy = "None"
          dnsConfig = {
            nameservers = ["127.0.0.1"]
          }
          setHostnameAsFQDN = true
          subdomain         = "ipa"
          
          hostAliases = [{
            ip        = var.ipa_ip_address
            hostnames = [var.ipa_hostname] 
          }]

          containers = [{
            name  = "freeipa-server"
            image = "freeipa/freeipa-server:almalinux-9"
            
            securityContext = {
              privileged             = false
              capabilities = {
                add = ["SYS_ADMIN", "FOWNER", "CHOWN", "SYS_RESOURCE"]
              }
            }

            env = [
              { name = "IPA_SERVER_INSTALL_OPTS", value = "-U -r ${var.ipa_realm} --ip-address=${var.ipa_ip_address} --no-host-dns -n ${var.domain_name} -p ${var.ds_password} -a ${var.admin_password} --hostname ${var.ipa_hostname}" }
            ]
            readinessProbe = {
              exec = {
                command = ["/usr/bin/systemctl", "status", "ipa"]
              }
              initialDelaySeconds = 60
              timeoutSeconds      = 10
              periodSeconds       = 10
            }

            volumeMounts = [{
              name      = "data"
              mountPath = "/data"
            }]
          }]
          volumes = [{
            name = "data"
            persistentVolumeClaim = {
              claimName = "freeipa-data-pvc"
            }
          }]
        }
      }
    }
  }
}
resource "kubernetes_manifest" "freeipa_service" {
  manifest = {
    apiVersion = "v1"
    kind       = "Service"
    metadata = {
      name      = "freeipa-service"
      namespace = kubernetes_namespace_v1.freeipa.metadata[0].name
      annotations = {
        "metallb.universe.tf/loadBalancerIPs" = "${var.ipa_ip_address}"
      }
    }
    spec = {
      type = "LoadBalancer"
      selector = { app = "freeipa" }
      ports = [
        { name = "http",         port = 80,   targetPort = 80 },
        { name = "https",        port = 443,  targetPort = 443 },
        { name = "dns-tcp",      port = 53,   targetPort = 53, protocol = "TCP" },
        { name = "dns-udp",      port = 53,   targetPort = 53, protocol = "UDP" },
        { name = "ldap",         port = 389,  targetPort = 389 },
        { name = "ldaps",        port = 636,  targetPort = 636 },
        { name = "kerberos-udp", port = 88,   targetPort = 88, protocol = "UDP" },
        { name = "kpasswd-udp",  port = 464,  targetPort = 464, protocol = "UDP" }
      ]
    }
  }
}
