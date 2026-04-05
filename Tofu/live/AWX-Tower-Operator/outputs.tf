
output "awx_node_port" {


  value = data.kubernetes_service_v1.awx_svc.spec[0].port[0].node_port


  description = "The port assigned to the service on each cluster node."


}





output "awx_internal_node_url" {


  value = "http://<ANY_NODE_IP>:${data.kubernetes_service_v1.awx_svc.spec[0].port[0].node_port}"


}





output "awx_admin_password" {


  value     = data.kubernetes_secret_v1.awx_admin_password.data["password"]


  sensitive = true


}
