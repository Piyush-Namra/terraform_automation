resource "google_bigquery_table" "bq_tables" {
  for_each = { for idx, table in local.tables_flattened : "${table["datasetId"]}_${table["tableId"]}" => table }

  project    = var.project_id
  labels     = each.value.labels
  dataset_id = each.value["datasetId"]
  table_id   = each.value["tableId"]
  clustering = each.value["clustering"]
  deletion_protection = each.value["deletionProtection"] 
  dynamic "time_partitioning" {
    for_each = each.value["partitionType"] != null ? [1] : []

    content {
      type                     = each.value["partitionType"]
      field                    = each.value["partitionField"]
      expiration_ms            = each.value["expirationMs"]
      # require_partition_filter = each.value["requirePartitionFilter"]
    }
  }

  schema = file("${path.module}/../${each.value["tableSchemaPath"]}")
  encryption_configuration {
    kms_key_name = var.kms_key_self_link
  }
}
