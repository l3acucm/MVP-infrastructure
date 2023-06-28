resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  count   = length(var.projects)
  comment = var.projects[count.index].domain
}

resource "aws_cloudfront_distribution" "website_distribution" {
  count   = length(var.projects)
  enabled = true


  origin {
    domain_name = aws_s3_bucket.frontend_bucket[count.index].website_endpoint
    origin_id   = var.projects[count.index].domain

    custom_origin_config {
      http_port              = "80"
      https_port             = "443"
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2"]
    }
  }

  custom_error_response {
    error_caching_min_ttl = 10
    error_code            = 404
    response_code         = 200
    response_page_path    = "/index.html"
  }

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = var.projects[count.index].domain
    cache_policy_id = "658327ea-f89d-4fab-a63d-7e88639e58f6"

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 0
    max_ttl                = 0
  }
  aliases = [var.projects[count.index].domain]

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn = aws_acm_certificate.default[count.index].arn
    ssl_support_method  = "sni-only"
  }

  provisioner "local-exec" {
    command = "aws cloudfront create-invalidation --distribution-id ${self.id} --paths '/*'"
  }
  depends_on = [cloudflare_record.cloudfront_dns_verification]
}

