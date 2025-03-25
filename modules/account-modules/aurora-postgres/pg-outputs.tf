
# Extract the writer hostname and port
locals {
  writer_endpoint_parts = split(":", aws_rds_cluster.aurora_postgres_cluster.endpoint)
  writer_hostname       = local.writer_endpoint_parts[0]
  # writer_port           = local.writer_endpoint_parts[1]

  reader_endpoint_parts = split(":", aws_rds_cluster.aurora_postgres_cluster.reader_endpoint)
  reader_hostname       = local.reader_endpoint_parts[0]
  # reader_port           = local.reader_endpoint_parts[1]
}

# Output the writer hostname and port separately
output "writer_hostname" {
  description = "The hostname for the writer endpoint of the Aurora PostgreSQL cluster"
  value       = local.writer_hostname
}


# Output the reader hostname and port separately
output "reader_hostname" {
  description = "The hostname for the reader endpoint of the Aurora PostgreSQL cluster"
  value       = local.reader_hostname
}
