
resource "aws_acm_certificate" "default" {
  count                     = length(var.projects)
  provider                  = aws.for_certificates
  domain_name               = var.projects[count.index].domain
  subject_alternative_names = ["*.${var.projects[count.index].domain}"]
  validation_method         = "DNS"
  lifecycle {
    create_before_destroy = true
  }
}
