variable "project_id" {
  description = "Google Cloud project ID"
  type        = string
}

variable "location" {
  description = "Project location"
  type        = string
  default     = "eu-west1"
}

variable "region" {
  description = "The project region"
  type        = string
}

variable "labels" {
  description = "Labels resources created by this utility"
  type        = map(string)
  default     = {}
}