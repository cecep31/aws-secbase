resource "aws_config_configuration_recorder" "this" {
  name     = var.name
  role_arn = var.role_arn

  recording_group {
    all_supported                 = true
    include_global_resource_types = var.include_global_resource_types
  }
}

resource "aws_config_delivery_channel" "this" {
  name           = var.name
  s3_bucket_name = var.s3_bucket_name

  snapshot_delivery_properties {
    delivery_frequency = var.snapshot_delivery_frequency
  }

  depends_on = [aws_config_configuration_recorder.this]
}

resource "aws_config_configuration_recorder_status" "this" {
  name       = aws_config_configuration_recorder.this.name
  is_enabled = true

  depends_on = [aws_config_delivery_channel.this]
}

resource "aws_config_config_rule" "this" {
  for_each = var.rules

  name             = each.key
  input_parameters = each.value.input_parameters == null ? null : jsonencode(each.value.input_parameters)

  source {
    owner             = "AWS"
    source_identifier = each.value.identifier
  }

  tags = var.tags

  depends_on = [aws_config_configuration_recorder_status.this]
}
