output "kms_key_self_link" {
  value = google_kms_crypto_key.key.id
}