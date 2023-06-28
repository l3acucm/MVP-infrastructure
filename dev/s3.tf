//global
resource "aws_s3_bucket" "backups_bucket" {
  bucket = var.aws_s3_backups_bucket_name
  lifecycle {
    prevent_destroy = true
  }
}
// per-project
resource "aws_s3_bucket" "frontend_bucket" {
  count  = length(var.projects)
  bucket = var.projects[count.index].website_bucket_name
  tags   = {
    type = "website"
  }
}


resource "aws_s3_bucket_ownership_controls" "allow_acl_to_website_bucket" {
  count  = length(var.projects)
  bucket = aws_s3_bucket.frontend_bucket[count.index].id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_website_configuration" "example" {
  count  = length(var.projects)
  bucket = aws_s3_bucket.frontend_bucket[count.index].id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }

  routing_rule {
    condition {
      key_prefix_equals = "docs/"
    }
    redirect {
      replace_key_prefix_with = "documents/"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "s3_website_public_access" {
  count  = length(var.projects)
  bucket = aws_s3_bucket.frontend_bucket[count.index].id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "website_policy" {
  count  = length(var.projects)
  bucket = aws_s3_bucket.frontend_bucket[count.index].bucket
  policy = data.aws_iam_policy_document.public_website_policy_document[count.index].json
}

data "aws_iam_policy_document" "public_website_policy_document" {
  count = length(var.projects)
  statement {
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions = [
      "s3:GetObject",
    ]
    resources = [
      "${aws_s3_bucket.frontend_bucket[count.index].arn}/*",
      aws_s3_bucket.frontend_bucket[count.index].arn,
    ]
  }

  statement {
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    effect = "Deny"
    actions = [
      "s3:GetObject",
    ]
    resources = [
      "${aws_s3_bucket.frontend_bucket[count.index].arn}/media/private/*",
    ]
  }
}
