# terraform-aws-alb

Terraform module for an Application Load Balancer. Target groups and
listeners are separate modules —
[`terraform-aws-alb-target-group`](https://github.com/kn47ytv9mv/terraform-aws-alb-target-group)
and
[`terraform-aws-alb-listener`](https://github.com/kn47ytv9mv/terraform-aws-alb-listener)
— since one load balancer can have several of each.

## Cost

An Application Load Balancer bills hourly for as long as it exists,
plus a per-hour charge based on Load Balancer Capacity Units consumed.
Both charges apply regardless of whether the load balancer is actively
serving traffic. See AWS's
[Elastic Load Balancing pricing](https://aws.amazon.com/elasticloadbalancing/pricing/)
page for current rates.

## Design

AWS requires an Application Load Balancer to span at least two
availability zones, so `subnet_ids` is validated to have at least two
entries — but that only checks the count, not actual AZ diversity,
since confirming that would need a `data` source lookup this module
deliberately avoids (every module in this family is a pure
passthrough, with no AWS API calls beyond the resource it manages).
Two subnets sharing an AZ still pass here, only failing once AWS's own
`CreateLoadBalancer` call rejects it directly.

### Logging

Supplying `access_logs_bucket` enables access logging automatically —
there is no separate switch to remember. Access logging itself costs
nothing beyond the S3 storage the logs occupy, which is why supplying a
destination is treated as intent to log rather than requiring a second
opt-in. `access_logs_enabled = false` turns delivery off while leaving
the bucket configured.

`connection_logs_bucket` follows the same pattern and records TLS
handshake and client connection detail that access logs do not.

## Usage

```hcl
module "alb" {
  source = "kn47ytv9mv/alb/aws"

  subnet_ids         = module.public_subnets[*].id
  security_group_ids = [module.alb_security_group.id]
}
```

Or directly from this repository:

```hcl
module "alb" {
  source = "github.com/kn47ytv9mv/terraform-aws-alb"

  subnet_ids         = module.public_subnets[*].id
  security_group_ids = [module.alb_security_group.id]
}
```

## Requirements

| Name | Version |
|---|---|
| terraform | >= 1.2 |
| aws | ~> 6.61 |
| random | ~> 3.9 |

## Providers

| Name | Version |
|---|---|
| aws | ~> 6.61 |
| random | ~> 3.9 |

## Inputs

| Name | Description | Default | Required |
|---|---|---|---|
| name | The name of the load balancer. If null, a unique name is generated. | `null` | no |
| internal | Whether the load balancer is internal (private) rather than internet-facing. | `true` | no |
| subnet_ids | IDs of the subnets to attach the load balancer to. AWS requires at least two, in different availability zones. | `null` | no |
| security_group_ids | IDs of the security groups to associate with the load balancer. | `null` | no |
| drop_invalid_header_fields | Whether the load balancer drops HTTP headers that do not conform to RFC 7230, rather than passing them through to targets. | `true` | no |
| tags | A map of tags to assign to the load balancer. | `null` | no |
| access_logs_bucket | Name of an S3 bucket receiving access logs. Supplying a bucket enables logging automatically; the bucket policy must allow the ELB log delivery service to write. | `null` | no |
| access_logs_prefix | Prefix for access log object keys, before the `AWSLogs/<account-id>/` path AWS adds. | `null` | no |
| access_logs_enabled | Whether access log delivery is active, for turning it off without unsetting the bucket. | `null` | no |
| connection_logs_bucket | Name of an S3 bucket receiving connection logs, which record TLS handshake and client connection detail access logs do not. | `null` | no |
| connection_logs_prefix | Prefix for connection log object keys. | `null` | no |
| connection_logs_enabled | Whether connection log delivery is active, for turning it off without unsetting the bucket. | `null` | no |

## Outputs

| Name | Description |
|---|---|
| id | The ID of the load balancer. |
| arn | The ARN of the load balancer. |
| zone_id | The Route 53 hosted zone ID of the load balancer, for alias records. |
| dns_name | The DNS name of the load balancer. |
| arn_suffix | The portion of the ARN CloudWatch uses as its `LoadBalancer` dimension. Feed this into `terraform-aws-monitoring-baseline` — the full ARN matches no metrics. |
| name | The name of the load balancer. |

## License

MIT — see [LICENSE.md](LICENSE.md).
