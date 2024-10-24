module "bigquery_datasets" {
  source = "./modules/bigquery/bq_datasets"
  project_id = var.project_id
  region = var.region
  location = var.location
}

module "bigquery_tables" {
  source = "./modules/bigquery/bq_tables"
  project_id = var.project_id
  region = var.region
  depends_on = [ module.bigquery_datasets ]
}