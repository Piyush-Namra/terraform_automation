variable "project_id" {
  type        = string
  description = "The GCP Project ID to create resources in."
}


variable "region" {
  type        = string
  description = "The GCP Project ID to create resources in."
}

variable "labels" {
  description = "Labels for BigQuery table"
  type        = map(string)
  default     = {}
}

# variable "crypto_key" {
#   type = string
#   description = "value" 
# }