
resource "cloudflare_record" "api" {
  count   = length(var.projects)
  zone_id = var.projects[count.index].cloudflare_zone_id
  name    = var.projects[count.index].backend_a_record
  value   = aws_instance.backend_ec2_instance[count.index].public_ip
  type    = "A"
  ttl     = 1
  proxied = true
}

resource "cloudflare_record" "frontend" {
  count   = length(var.projects)
  zone_id = var.projects[count.index].cloudflare_zone_id
  name    = var.projects[count.index].frontend_a_record
  value   = aws_cloudfront_distribution.website_distribution[count.index].domain_name
  type    = "CNAME"
  ttl     = 1
  proxied = true
}



resource "cloudflare_record" "cloudfront_dns_verification" {
  count   = length(var.projects)
  zone_id = var.projects[count.index].cloudflare_zone_id
  name    = tolist(aws_acm_certificate.default[count.index].domain_validation_options)[0].resource_record_name
  value   = tolist(aws_acm_certificate.default[count.index].domain_validation_options)[0].resource_record_value
  type    = tolist(aws_acm_certificate.default[count.index].domain_validation_options)[0].resource_record_type
  ttl     = 1
  proxied = false
}
