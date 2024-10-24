locals {
  datasetsArray = jsondecode(file("${path.module} /../datasets_with_tables.json"))
  datasetsMap   = { for idx, val in local.datasetsArray : idx => val }
}
