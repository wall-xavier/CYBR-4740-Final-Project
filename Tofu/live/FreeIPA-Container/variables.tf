variable "k8s_config_raw" {

  description = "Raw configuration pulled from R2"
  type        = string

}

variable "admin_password" {

  description = "Admin password for FreeIPA"
  type = string

}

variable "ds_password" {

  description = "Password for the IPA datastore"
  type = string

}

variable "ipa_hostname" {

  description = "Hostname of the IPA server"
  type = string

}

variable "ipa_ip_address" {

  description = "IP address for the IPA serer to use"
  type = string

}

variable "ipa_realm" {

  description = "The realm of the IPA server"
  type = string

}

variable "domain_name" {

  description = "Domain name for the IPA service"
  type = string

}
