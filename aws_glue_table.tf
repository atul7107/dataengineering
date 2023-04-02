resource "aws_glue_catalog_table" "dl_glue_catalog_test_table" {
  
  for_each = toset(var.dl_s3_prefixes)
  
  name           = "${each.key}_test_table"
  database_name  = aws_glue_catalog_database.data["raw"].name
  
  partition_keys {
      name = "id_date"
      type = "string"
  }

  parameters = {
      "classification"                   = "csv",
      "skip.header.line.count"           = "1",
      "CrawlerSchemaSerializerVersion"   = "1.0",
      "CrawlerSchemaDeserializerVersion" = "1.0",
      "compressionType"                  = "none",
      "typeOfData"                       = "file",
      "delimiter"                        = "|",
      "columnsOrdered"                   = "true",
      "areColumnsQuoted"                 = "false"
  }

  storage_descriptor {
    location      = "s3://${module.dl_s3_raw.s3_bucket_id}/${each.key}/test_table/"
    input_format  = "org.apache.hadoop.mapred.TextInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat"

    ser_de_info {
        
        serialization_library = "org.apache.hadoop.hive.serde2.OpenCSVSerde"

        parameters = {
            "escapeChar"    = "\\"
            "separatorChar" = "|",
            "quoteChar"     = "\""
        }
    }

    columns {
      name = "id"
      type = "string"
    }

    columns {
      name = "description"
      type = "string"
    }
  }
}
