variable "project_id" {
  description = "Google Cloud project ID"
  type        = string
}

variable "region" {
  description = "The BigQuery dataset ID"
  type        = string
}

variable "location" {
  description = "The BigQuery dataset ID location"
  type        = string
}

variable "labels" {
  description = "Labels for dataset"
  type        = map(string)
  default     = {}
}