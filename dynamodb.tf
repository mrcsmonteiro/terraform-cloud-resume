# DynamoDB Table to store the visitor count
resource "aws_dynamodb_table" "visitor_counts" {
  name         = "PageViews"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }

  tags = local.common_tags
}

resource "aws_dynamodb_table_item" "global_count" {
  table_name = aws_dynamodb_table.visitor_counts.name
  hash_key   = aws_dynamodb_table.visitor_counts.hash_key

  item = jsonencode({
    id     = { S = "global_count" }
    visits = { N = "0" }
  })

  # This lifecycle block prevents the item from being updated.
  lifecycle {
    # It tells Terraform to ignore changes to the 'item' attribute after the initial creation.
    # The 'item' attribute contains the 'visits' count, which should be managed by the application.
    ignore_changes = [
      item
    ]
  }
}