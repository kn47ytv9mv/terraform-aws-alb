mock_provider "aws" {}

run "rejects_fewer_than_two_subnets" {
  command = plan

  variables {
    subnet_ids = ["subnet-0123456789abcdef0"]
  }

  expect_failures = [var.subnet_ids]
}

run "default_config_creates_expected_resources" {
  command = apply

  variables {
    subnet_ids = ["subnet-0123456789abcdef0", "subnet-0123456789abcdef1"]
  }

  assert {
    condition     = aws_lb.resource.internal == true
    error_message = "internal should default to true (private by default)."
  }

  assert {
    condition     = aws_lb.resource.drop_invalid_header_fields == true
    error_message = "drop_invalid_header_fields should default to true."
  }

  assert {
    condition     = length(aws_lb.resource.name) == 32
    error_message = "When name is left unset, the random_uuid fallback should be truncated to AWS's 32-character limit."
  }
}

run "explicit_name_used_as_is" {
  command = plan

  variables {
    name       = "my-custom-alb"
    subnet_ids = ["subnet-0123456789abcdef0", "subnet-0123456789abcdef1"]
  }

  assert {
    condition     = aws_lb.resource.name == "my-custom-alb"
    error_message = "A supplied name should be used as-is, not replaced by the random fallback."
  }
}

run "internal_false_for_internet_facing" {
  command = plan

  variables {
    internal   = false
    subnet_ids = ["subnet-0123456789abcdef0", "subnet-0123456789abcdef1"]
  }

  assert {
    condition     = aws_lb.resource.internal == false
    error_message = "internal = false should be passed straight through."
  }
}

run "no_access_logs_by_default" {
  command = plan

  variables {
    subnet_ids = ["subnet-1111", "subnet-2222"]
  }

  assert {
    condition     = length(aws_lb.resource.access_logs) == 0
    error_message = "Leaving access_logs_bucket unset should emit no access_logs block, since there is nowhere to write."
  }
}

run "supplying_a_bucket_enables_access_logs" {
  command = plan

  variables {
    subnet_ids         = ["subnet-1111", "subnet-2222"]
    access_logs_bucket = "lb-logs"
  }

  assert {
    condition     = aws_lb.resource.access_logs[0].enabled == true
    error_message = "Supplying a bucket should enable access logging automatically, with no separate switch to remember."
  }

  assert {
    condition     = aws_lb.resource.access_logs[0].bucket == "lb-logs"
    error_message = "The access log bucket should pass through unchanged."
  }
}

run "access_logs_can_be_disabled_without_unsetting_the_bucket" {
  command = plan

  variables {
    subnet_ids          = ["subnet-1111", "subnet-2222"]
    access_logs_bucket  = "lb-logs"
    access_logs_enabled = false
  }

  assert {
    condition     = aws_lb.resource.access_logs[0].enabled == false
    error_message = "An explicit false should turn delivery off while leaving the bucket configured."
  }
}

run "connection_logs_follow_the_same_pattern" {
  command = plan

  variables {
    subnet_ids             = ["subnet-1111", "subnet-2222"]
    connection_logs_bucket = "lb-logs"
  }

  assert {
    condition     = aws_lb.resource.connection_logs[0].enabled == true
    error_message = "Supplying a connection log bucket should enable connection logging automatically."
  }
}

run "readme_default_usage" {
  command = plan

  variables {
    subnet_ids         = ["subnet-0123456789abcdef0", "subnet-0123456789abcdef1"]
    security_group_ids = ["sg-0123456789abcdef0"]
  }
}
