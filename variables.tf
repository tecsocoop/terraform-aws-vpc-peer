variable "name" {
  description = "Name of the local (requester) side, used to build the peering connection Name tag - example: prd"
  type        = string
}

variable "peer_name" {
  description = "Name of the peer (accepter) side, used to build the peering connection Name tag - example: uat"
  type        = string
}

variable "vpc_id" {
  description = "Local (requester) VPC id - example: module.vpc.vpc_id"
  type        = string
}

variable "vpc_cidr_block" {
  description = "Local (requester) VPC CIDR block, used for the route added in the peer route tables - example: module.vpc.vpc_cidr_block"
  type        = string
}

variable "peer_vpc_id" {
  description = "Peer (accepter) VPC id"
  type        = string
}

variable "peer_vpc_cidr_block" {
  description = "Peer (accepter) VPC CIDR block, used for the route added in the local route tables. If null, it is looked up automatically with a data \"aws_vpc\" source using peer_vpc_id (only possible for same-account peering)."
  type        = string
  default     = null
}

variable "peer_owner_id" {
  description = "AWS account id of the peer VPC owner. Required only for cross-account peering."
  type        = string
  default     = null
}

variable "peer_region" {
  description = "AWS region of the peer VPC. Required only for cross-region peering."
  type        = string
  default     = null
}

variable "auto_accept" {
  description = "Auto accept the peering connection. Only works for same-account, same-region peering; leave false and accept the connection separately for cross-account/cross-region peering."
  type        = bool
  default     = true
}

variable "allow_remote_vpc_dns_resolution" {
  description = "Allow DNS resolution across the peering connection, applied to both the accepter and requester side."
  type        = bool
  default     = true
}

variable "local_route_table_ids" {
  description = "Route tables in the local (requester) VPC where the route toward the peer CIDR is created. Key = Name suffix (e.g. public, private). Value = route table id."
  type        = map(string)
  default     = {}
}

variable "peer_route_table_ids" {
  description = "Route tables in the peer (accepter) VPC where the route back toward the local CIDR is created. Key = Name suffix (e.g. public, private). Value = route table id. Only usable when the peer route tables are reachable, i.e. same-account peering."
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "Additional tags applied to the peering connection, merged with the Name tag."
  type        = map(string)
  default     = {}
}
