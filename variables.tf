variable "name" {
  default     = null
  description = "The name of the load balancer. If null, a unique name is generated."
}

variable "internal" {
  default     = true
  description = "Whether the load balancer is internal (private) rather than internet-facing."
}

variable "subnet_ids" {
  default     = null
  description = "IDs of the subnets to attach the load balancer to. AWS requires at least two, in different availability zones."

  validation {
    condition     = var.subnet_ids == null || length(var.subnet_ids) >= 2
    error_message = "subnet_ids needs at least two subnets — AWS requires an Application Load Balancer to span at least two availability zones. This only checks the count, not that they are in different AZs."
  }
}

variable "security_group_ids" {
  default     = null
  description = "IDs of the security groups to associate with the load balancer."
}

variable "drop_invalid_header_fields" {
  default     = true
  description = "Whether the load balancer drops HTTP headers that do not conform to RFC 7230, rather than passing them through to targets."
}

variable "access_logs_bucket" {
  default     = null
  description = "Name of an S3 bucket receiving access logs, one line per request. Supplying a bucket enables logging automatically — there is no separate switch to remember, and access logging costs nothing beyond the S3 storage the logs occupy. The bucket's policy must allow the ELB log delivery service to write to it. If null, no access logs are delivered."
}

variable "access_logs_prefix" {
  default     = null
  description = "Prefix for access log object keys, before the AWSLogs/<account-id>/ path AWS adds automatically."
}

variable "access_logs_enabled" {
  default     = null
  description = "Whether access log delivery is active, for turning it off without unsetting access_logs_bucket. If null, logging is enabled whenever access_logs_bucket is set."
}

variable "connection_logs_bucket" {
  default     = null
  description = "Name of an S3 bucket receiving connection logs, which record TLS handshake and client connection detail that access logs do not. Supplying a bucket enables them automatically. If null, no connection logs are delivered."
}

variable "connection_logs_prefix" {
  default     = null
  description = "Prefix for connection log object keys."
}

variable "connection_logs_enabled" {
  default     = null
  description = "Whether connection log delivery is active, for turning it off without unsetting connection_logs_bucket. If null, logging is enabled whenever connection_logs_bucket is set."
}

variable "tags" {
  default     = null
  description = "A map of tags to assign to the load balancer."
}
