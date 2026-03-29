terraform{
	required_providers{
		cloudflare = {
			source = "cloudflare/cloudflare"
			version = "5.19.0-beta.3"
		}
	}
}

provider "cloudflare" {

	api_token = var.cloudflare_api_token

}

resource "cloudflare_r2_bucket" "backend_bucket" {

	account_id = var.account_id
	name = var.bucket_name
	location = var.bucket_location
	storage_class = var.storage_class

}
