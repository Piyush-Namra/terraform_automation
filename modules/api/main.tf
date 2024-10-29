# Enable necessary APIs
resource "google_project_service" "apis" {
  for_each = toset([
    "compute.googleapis.com",
    "storage.googleapis.com",
    "bigquery.googleapis.com",
    "dataflow.googleapis.com",
    "iam.googleapis.com",
    "cloudkms.googleapis.com",
    "networksecurity.googleapis.com"
  ])
  service            = each.value
  disable_on_destroy = false
  disable_dependent_services=true
}