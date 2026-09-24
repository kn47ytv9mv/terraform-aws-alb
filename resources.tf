resource "random_uuid" "resource" {}

resource "aws_lb" "resource" {
  name                       = coalesce(var.name, substr(random_uuid.resource.id, 0, 32))
  internal                   = var.internal
  subnets                    = var.subnet_ids
  security_groups            = var.security_group_ids
  drop_invalid_header_fields = var.drop_invalid_header_fields

  load_balancer_type = "application"

  dynamic "access_logs" {
    for_each = var.access_logs_bucket[*]

    content {
      bucket  = access_logs.value
      prefix  = var.access_logs_prefix
      enabled = coalesce(var.access_logs_enabled, true)
    }
  }

  dynamic "connection_logs" {
    for_each = var.connection_logs_bucket[*]

    content {
      bucket  = connection_logs.value
      prefix  = var.connection_logs_prefix
      enabled = coalesce(var.connection_logs_enabled, true)
    }
  }

  tags = var.tags
}

output "id" {
  description = "The ID of the load balancer."
  value       = aws_lb.resource.id
}

output "name" {
  description = "The name of the load balancer."
  value       = aws_lb.resource.name
}

output "arn" {
  description = "The ARN of the load balancer."
  value       = aws_lb.resource.arn
}

output "arn_suffix" {
  description = "The portion of the ARN CloudWatch uses as its LoadBalancer dimension. Feed this into terraform-aws-monitoring-baseline's load_balancers — the full ARN matches no metrics."
  value       = aws_lb.resource.arn_suffix
}

output "zone_id" {
  description = "The Route 53 hosted zone ID of the load balancer, for alias records."
  value       = aws_lb.resource.zone_id
}

output "dns_name" {
  description = "The DNS name of the load balancer."
  value       = aws_lb.resource.dns_name
}
