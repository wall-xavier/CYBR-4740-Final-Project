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
          terminationGracePeriodSeconds = 60
          securityContext = {
            fsGroup = 0
          }
          hostAliases = [{
            ip        = var.ipa_ip_address
            hostnames = [var.ipa_hostname] 
          }]
          containers = [{
            name  = "freeipa-server"
            image = "freeipa/freeipa-server:almalinux-9"
            
            resources = {
              requests = {
                cpu    = "1"
                memory = "2Gi"
              }
              limits = {
                cpu    = "2"
                memory = "4Gi"
              }
           }

            startupProbe = {
              httpGet = {
                path   = "/ipa/ui/"
                port   = 443
                scheme = "HTTPS"
              }
              failureThreshold = 30
              periodSeconds    = 20
            }
            readinessProbe = {
              httpGet = {
                path   = "/ipa/ui/"
                port   = 443
                scheme = "HTTPS"
              }
              initialDelaySeconds = 10
              periodSeconds       = 10
            }

            securityContext = {
              privileged = false
              capabilities = {
                add = ["SYS_ADMIN", "FOWNER", "CHOWN", "SYS_RESOURCE"]
              }
            }

            env = [
              { name = "DEBUG_TRACE",           value = "1" },
              { name = "DEBUG_NO_EXIT",         value = "1" },
              { name = "IPA_SERVER_HOSTNAME", value = "${var.ipa_hostname}" },
              { name = "IPA_SERVER_IP",       value = "${var.ipa_ip_address}" },
              { name = "PASSWORD",            value = "${var.ipa_password}" },
              { name = "IPA_SERVER_INSTALL_OPTS", value = "--unattended --no-ntp --skip-mem-check" }
            ]

            ports = [
              { containerPort = 80,  name = "http" },
              { containerPort = 443, name = "https" },
              { containerPort = 389, name = "ldap" },
              { containerPort = 636, name = "ldaps" },
              { containerPort = 88,  name = "kerberos-udp", protocol = "UDP" },
              { containerPort = 464, name = "kpasswd-udp",  protocol = "UDP" }
            ]

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
        { name = "http",     port = 80,   targetPort = 80 },
        { name = "https",    port = 443,  targetPort = 443 },
        { name = "ldap",     port = 389,  targetPort = 389 },
        { name = "ldaps",    port = 636,  targetPort = 636 },
        { name = "kerberos", port = 88,   targetPort = 88, protocol = "UDP" }
      ]
    }
  }
}

