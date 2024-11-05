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
  default     = "eu-west1"
}

variable "labels" {
  description = "Labels resources created by this utility"
  type        = map(string)
  default     = {}
}

# KMS related variables

# KMS Variables
variable "kms_keyring_name" {
  type = string
  default = ""
}

variable "kms_location" {
  type = string
  default = "europe-west1"
}

variable "kms_key_name" {
  type = string
  default = ""
}

variable "kms_purpose" {
  type    = string
  default = "ENCRYPT_DECRYPT"
}