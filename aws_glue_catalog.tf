resource "aws_glue_catalog_database" "db_data" {
  count = length(var.region_availability_zones)

  name = "${var.dl_glue_raw_db}_${element(var.region_availability_zones, count.index)}"
}



#resource "aws_glue_catalog_database" "db_data" {

  #for_each = toset(var.dl_zones)

  #name        = "${var.dl_catalog_db.name}_${each.key}"
  #description = "${var.dl_catalog_db.description} ${upper(each.key)} zone"

#}
