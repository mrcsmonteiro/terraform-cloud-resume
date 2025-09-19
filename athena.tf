resource "aws_athena_database" "cloudfront_logs_db" {
  name   = "cloudfront_logs"
  bucket = aws_s3_bucket.cloudfront_logs_bucket.id
}

resource "aws_glue_catalog_table" "cloudfront_logs_table" {
  name          = "cloudfront_logs_table"
  database_name = aws_athena_database.cloudfront_logs_db.name

  table_type = "EXTERNAL_TABLE"

  parameters = {
    "EXTERNAL"                  = "TRUE"
    "skip.header.line.count"    = "2"
    "serialization.null.format" = "-"
  }

  storage_descriptor {
    location = "s3://${aws_s3_bucket.cloudfront_logs_bucket.id}/${var.log_prefix}/"

    input_format  = "org.apache.hadoop.mapred.TextInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat"

    ser_de_info {
      name                  = "cloudfront_serde"
      serialization_library = "org.apache.hadoop.hive.serde2.lazy.LazySimpleSerDe"

      parameters = {
        "serialization.format" = "\t"
        "field.delim"          = "\t"
        "escape.delim"         = "\\"
      }
    }

    columns {
      name = "date"
      type = "string"
    }

    columns {
      name = "time"
      type = "string"
    }

    columns {
      name = "x_edge_location"
      type = "string"
    }

    columns {
      name = "sc_bytes"
      type = "bigint"
    }

    columns {
      name = "c_ip"
      type = "string"
    }

    columns {
      name = "cs_method"
      type = "string"
    }

    columns {
      name = "cs_host"
      type = "string"
    }

    columns {
      name = "cs_uri_stem"
      type = "string"
    }

    columns {
      name = "cs_status"
      type = "int"
    }

    columns {
      name = "cs_referer"
      type = "string"
    }

    columns {
      name = "cs_user_agent"
      type = "string"
    }

    columns {
      name = "cs_uri_query"
      type = "string"
    }

    columns {
      name = "cs_cookies"
      type = "string"
    }

    columns {
      name = "cs_x_edge_result_type"
      type = "string"
    }

    columns {
      name = "sc_ssl_protocol"
      type = "string"
    }

    columns {
      name = "sc_ssl_cipher"
      type = "string"
    }

    columns {
      name = "sc_cache_hit"
      type = "string"
    }

    columns {
      name = "cs_protocol"
      type = "string"
    }

    columns {
      name = "x_edge_request_id"
      type = "string"
    }

    columns {
      name = "x_edge_result_type"
      type = "string"
    }

    columns {
      name = "x_edge_detailed_result_type"
      type = "string"
    }

    columns {
      name = "x_edge_response_result_type"
      type = "string"
    }

    columns {
      name = "x_forwarded_for"
      type = "string"
    }

    columns {
      name = "x_edge_client_ip"
      type = "string"
    }
  }
}

# IAM role for Athena to access S3
resource "aws_iam_role" "athena_role" {
  name = "athena-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "athena.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      },
    ]
  })
}

# IAM policy to allow Athena access to S3 logs and query results
resource "aws_iam_role_policy" "athena_s3_policy" {
  name = "athena-s3-access"
  role = aws_iam_role.athena_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:Get*",
          "s3:List*",
          "s3:PutObject"
        ]
        Resource = [
          aws_s3_bucket.cloudfront_logs_bucket.arn,
          "${aws_s3_bucket.cloudfront_logs_bucket.arn}/*",
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
        ]
        Resource = [
          aws_s3_bucket.cloudfront_logs_bucket.arn,
          "${aws_s3_bucket.cloudfront_logs_bucket.arn}/*",
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetBucketLocation",
          "s3:ListBucket",
        ]
        Resource = [
          aws_s3_bucket.cloudfront_logs_bucket.arn,
        ]
      },
      {
        Effect   = "Allow"
        Action   = "s3:GetBucketLocation"
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "glue:GetDatabase",
          "glue:GetDatabases",
          "glue:GetTable",
          "glue:GetTables",
          "glue:GetPartitions",
          "glue:GetPartition",
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_athena_workgroup" "cloudfront_logs_workgroup" {
  name  = "cloudfront-logs-workgroup"
  state = "ENABLED"

  configuration {
    result_configuration {
      output_location = "s3://${aws_s3_bucket.cloudfront_logs_bucket.id}/query_results/"
    }
  }
}