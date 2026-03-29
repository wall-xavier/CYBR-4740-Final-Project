output "r2_url"{

	description = "A computed result of the R2 bucket URL"
	value = "https://${var.account_id}.r2.cloudflarestorage.com/${var.bucket_name}"

}
