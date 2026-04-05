variable "k8s_config_raw" {

  description = "Raw configuration pulled from R2"
  type        = string

}

variable "ipa_ip_address" {

  description = "IP Address of the FreeIPA server"
  type = string

}

variable "ipa_hostname" {

  description = "Hostname of the FreeIPA server"
  type = string

}

variable "ipa_password" {

  description = "Password of the FreeIPA Server"
  type = string

}
