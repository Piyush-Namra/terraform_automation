resource "google_kms_key_ring" "keyring" {
  name     = var.keyring_name
  location = var.location
}

resource "google_kms_crypto_key" "key" {
  name     = var.key_name
  key_ring = google_kms_key_ring.keyring.id
  purpose  = var.purpose
}