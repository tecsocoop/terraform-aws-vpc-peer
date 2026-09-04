output "vpc_peering_connection_id" {
  description = "ID of the VPC peering connection"
  value       = aws_vpc_peering_connection.this.id
}

output "accept_status" {
  description = "Status of the VPC peering connection request"
  value       = aws_vpc_peering_connection.this.accept_status
}
