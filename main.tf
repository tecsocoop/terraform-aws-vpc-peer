##############################################
######## Peer VPC CIDR block lookup #########
##############################################

data "aws_vpc" "peer" {
  count = var.peer_vpc_cidr_block == null ? 1 : 0
  id    = var.peer_vpc_id
}

locals {
  peer_vpc_cidr_block = coalesce(var.peer_vpc_cidr_block, try(data.aws_vpc.peer[0].cidr_block, null))
}

#####################################
######## Peering connection ########
#####################################

resource "aws_vpc_peering_connection" "this" {
  vpc_id        = var.vpc_id
  peer_vpc_id   = var.peer_vpc_id
  peer_owner_id = var.peer_owner_id
  peer_region   = var.peer_region
  auto_accept   = var.auto_accept

  accepter {
    allow_remote_vpc_dns_resolution = var.allow_remote_vpc_dns_resolution
  }

  requester {
    allow_remote_vpc_dns_resolution = var.allow_remote_vpc_dns_resolution
  }

  tags = merge(var.tags, {
    "Name" = "vpc peer ${var.peer_name} <-> ${var.name}"
  })
}

##########################################
######## Routes -> local VPC side ########
##########################################

resource "aws_route" "local" {
  for_each = var.local_route_table_ids

  route_table_id            = each.value
  destination_cidr_block    = local.peer_vpc_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.this.id
}

#########################################
######## Routes -> peer VPC side ########
#########################################

resource "aws_route" "peer" {
  for_each = var.peer_route_table_ids

  route_table_id            = each.value
  destination_cidr_block    = var.vpc_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.this.id
}
