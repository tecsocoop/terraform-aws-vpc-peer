# terraform-aws-vpc-peer

Terraform module to standardize VPC peering connections between two VPCs:
creates the `aws_vpc_peering_connection`, and the routes on both sides
(local and peer route tables) pointing to each other's CIDR block.

Designed to be used together with the `terraform-aws-vpc` module, consuming
its outputs (`vpc_id`, `vpc_cidr_block`, `public_route_table_id`,
`private_route_table_id`).

## Requirements

| Name      | Version   |
|-----------|-----------|
| terraform | >= 1.3.7  |
| aws       | >= 5.9.0  |

## Usage

Published on the [public Terraform Registry](https://registry.terraform.io/)
under the `tecsocoop` namespace.

Example: peering the `uat` environment with `sit` (same AWS account, same
region), added to `environments/uat/00_networking.tf`. The peer VPC/route
table ids are not known by the `terraform-aws-vpc` module of the other
environment, so declare them as plain values (e.g. in a `locals` block):

```hcl
locals {
  sit_vpc_id                  = "vpc-0123456789abcdef0"
  sit_public_route_table_id   = "rtb-0123456789abcdef0"
  sit_private_route_table_id  = "rtb-0fedcba9876543210"
}

data "aws_route_table" "sit_public" {
  route_table_id = local.sit_public_route_table_id
}

data "aws_route_table" "sit_private" {
  route_table_id = local.sit_private_route_table_id
}

module "vpc_peer_sit" {
  source  = "tecsocoop/vpc-peer/aws"
#  version = "X.X.X" # see the latest available tag

  name      = "uat"
  peer_name = "sit"

  vpc_id         = module.vpc.vpc_id
  vpc_cidr_block = module.vpc.vpc_cidr_block

  peer_vpc_id = local.sit_vpc_id

  local_route_table_ids = {
    public  = module.vpc.public_route_table_id
    private = module.vpc.private_route_table_id
  }

  peer_route_table_ids = {
    public  = data.aws_route_table.sit_public.id
    private = data.aws_route_table.sit_private.id
  }
}
```

> [!note]
> `peer_vpc_cidr_block` is optional: if omitted, the module looks it up
> automatically with a `data "aws_vpc"` source using `peer_vpc_id`. This only
> works when the peer VPC is reachable from the caller's provider (i.e.
> same-account peering). Pass it explicitly for cross-account peering.

> [!note]
> `local_route_table_ids` / `peer_route_table_ids` accept any number of route
> tables (not just public/private); the map key is only used to compose the
> `aws_route` resource address (`local["public"]`, `local["private"]`, etc.).

> [!note]
> `auto_accept = true` (default) only works for same-account, same-region
> peering. For cross-account or cross-region peering, set `auto_accept =
> false`, provide `peer_owner_id` / `peer_region`, and accept the connection
> with a separate `aws_vpc_peering_connection_accepter` resource in the peer
> account/region — not covered by this module.
> https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_peering_connection_accepter

<details>
<summary>Variables</summary>

| Variable                          | Description                                                              | Values                        | Default |
|-----------------------------------|---------------------------------------------------------------------------|--------------------------------|---------|
| `name`                            | Name of the local (requester) side, used for the Name tag.               | string - e.g. `uat`            | -       |
| `peer_name`                       | Name of the peer (accepter) side, used for the Name tag.                 | string - e.g. `sit`            | -       |
| `vpc_id`                          | Local (requester) VPC id.                                                | string                          | -       |
| `vpc_cidr_block`                  | Local (requester) VPC CIDR block.                                        | string                          | -       |
| `peer_vpc_id`                     | Peer (accepter) VPC id.                                                  | string                          | -       |
| `peer_vpc_cidr_block`             | Peer (accepter) VPC CIDR block. If `null`, looked up automatically.      | string                          | `null`  |
| `peer_owner_id`                   | AWS account id of the peer VPC owner (cross-account peering).           | string                          | `null`  |
| `peer_region`                     | AWS region of the peer VPC (cross-region peering).                      | string                          | `null`  |
| `auto_accept`                     | Auto accept the peering connection.                                      | bool                            | `true`  |
| `allow_remote_vpc_dns_resolution` | Allow DNS resolution across the peering connection (both sides).        | bool                            | `true`  |
| `local_route_table_ids`           | Local route tables where the route to the peer CIDR is created.          | `map(string)`                   | `{}`    |
| `peer_route_table_ids`            | Peer route tables where the route back to the local CIDR is created.     | `map(string)`                   | `{}`    |
| `tags`                            | Additional tags applied to the peering connection.                       | `map(string)`                   | `{}`    |

</details>

<details>
<summary>Outputs</summary>

| Output                      | Description                                        |
|------------------------------|-----------------------------------------------------|
| `vpc_peering_connection_id` | ID of the VPC peering connection.                   |
| `accept_status`             | Status of the VPC peering connection request.       |

</details>

## License

Licensed under the [Apache License 2.0](LICENSE).
# terraform-aws-vpc-peer
