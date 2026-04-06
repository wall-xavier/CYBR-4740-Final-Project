variable "k8s_config_raw" {

  description = "Raw configuration pulled from R2"
  type        = string

}


variable "env_ips" {

  description = "The mapping of the networks for each environment"
  type = map(object({
    addresses     = string
  }))
  default = {

    default = {
      addresses     = "172.16.0.200-172.16.0.254"
    }
    dev = {
      addresses     = "172.16.1.200-172.16.1.254"
    }
    prod = {
      addresses     = "172.16.2.200-172.16.2.254"
    }

  }
}

