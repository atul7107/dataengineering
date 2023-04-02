resource "aws_glue_catalog_database" "db_data" {

  for_each = toset(var.dl_zones)

  name        = "${var.dl_catalog_db.name}_${each.key}"
  description = "${var.dl_catalog_db.description} ${upper(each.key)} zone"

}
