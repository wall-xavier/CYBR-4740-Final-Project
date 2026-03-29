variable "account_id" {

	description = "Account ID used for the R2 storage"
	type = string
}

variable "cloudflare_api_token" {

	description = "API token used to authenticate to Cloudflare"
	type = string

}

variable "bucket_name" {

	description = "Name of the R2 bucket"
	type = string
	default = "cybr-4740-backend-bucket"

}

variable "storage_class" {

	description = "Storage class of the R2 bucket"
	type = string
	default = "Standard"

}

variable "bucket_location" {

	description = "Location the bucket will be stored"
	type = string
	default = "apac"

}

