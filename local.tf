locals {
  zone_prefix_map = {
    for zone, prefix in var.dl_s3_prefixes : zone => { zone = zone, s3_prefix = prefix }
  }
}
