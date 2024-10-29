module "api" {
  source = "./modules/api"  
}

module "bigquery_datasets" {
  source = "./modules/bigquery/bq_datasets"
  project_id = var.project_id
  region = var.region
  location = var.location
  depends_on = [ module.kms ]
}

module "bigquery_tables" {
  source = "./modules/bigquery/bq_tables"
  project_id = var.project_id
  region = var.region
  kms_key_self_link = module.kms.kms_key_self_link
  depends_on = [ module.bigquery_datasets ]
}


module "kms" {
  source         = "./modules/kms"
  keyring_name   = var.kms_keyring_name
  location       = var.kms_location
  key_name       = var.kms_key_name
  purpose        = var.kms_purpose
}