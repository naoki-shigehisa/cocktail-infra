data "aws_route53_zone" "host_route53_zone" {
  name = "${var.host_domain_name}"
}

resource "aws_route53_zone" "cocktail_api_route53_zone" {
  name = "api.${var.domain_name}"
}

resource "aws_route53_zone" "cocktail_img_route53_zone" {
  name = "img.${var.domain_name}"
}

resource "aws_route53_record" "cocktail_api_ns_record" {
  name    = aws_route53_zone.cocktail_api_route53_zone.name
  type    = "NS"
  zone_id = data.aws_route53_zone.host_route53_zone.id
  records = [
    aws_route53_zone.cocktail_api_route53_zone.name_servers[0],
    aws_route53_zone.cocktail_api_route53_zone.name_servers[1],
    aws_route53_zone.cocktail_api_route53_zone.name_servers[2],
    aws_route53_zone.cocktail_api_route53_zone.name_servers[3],
  ]
  ttl = 172800
}

resource "aws_route53_record" "cocktail_img_ns_record" {
  name    = aws_route53_zone.cocktail_img_route53_zone.name
  type    = "NS"
  zone_id = data.aws_route53_zone.host_route53_zone.id
  records = [
    aws_route53_zone.cocktail_img_route53_zone.name_servers[0],
    aws_route53_zone.cocktail_img_route53_zone.name_servers[1],
    aws_route53_zone.cocktail_img_route53_zone.name_servers[2],
    aws_route53_zone.cocktail_img_route53_zone.name_servers[3],
  ]
  ttl = 172800
}

resource "aws_route53_record" "cocktail_api_route53_record" {
  zone_id   = aws_route53_zone.cocktail_api_route53_zone.zone_id
  name      = aws_route53_zone.cocktail_api_route53_zone.name
  type      = "A"
 
  alias {
    name                   = aws_alb.cocktail_alb.dns_name
    zone_id                = aws_alb.cocktail_alb.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "cocktail_img_route53_record" {
  zone_id   = aws_route53_zone.cocktail_img_route53_zone.zone_id
  name      = aws_route53_zone.cocktail_img_route53_zone.name
  type      = "A"

  alias {
    name                   = aws_cloudfront_distribution.cocktail_image_cloudfront.domain_name
    zone_id                = aws_cloudfront_distribution.cocktail_image_cloudfront.hosted_zone_id
    evaluate_target_health = false
  }
}
 
resource "aws_acm_certificate" "cocktail_api_acm" {
  domain_name               = aws_route53_zone.cocktail_api_route53_zone.name
  subject_alternative_names = []
  validation_method         = "DNS"
 
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_acm_certificate" "cocktail_img_acm" {
  domain_name               = aws_route53_zone.cocktail_img_route53_zone.name
  subject_alternative_names = []
  validation_method         = "DNS"
  provider                  = aws.virginia
 
  lifecycle {
    create_before_destroy = true
  }
}
 
resource "aws_route53_record" "cocktail_api_certificates" {
  for_each = {
    for dvo in aws_acm_certificate.cocktail_api_acm.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }
  allow_overwrite = true
  name = each.value.name
  records = [each.value.record]
  type = each.value.type

  zone_id = aws_route53_zone.cocktail_api_route53_zone.id
  ttl     = 300
}

resource "aws_route53_record" "cocktail_img_certificates" {
  for_each = {
    for dvo in aws_acm_certificate.cocktail_img_acm.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }
  allow_overwrite = true
  name = each.value.name
  records = [each.value.record]
  type = each.value.type

  zone_id = aws_route53_zone.cocktail_img_route53_zone.id
  ttl     = 300
}

resource "aws_acm_certificate_validation" "cocktail_api_certificate_validations" {
  for_each = aws_route53_record.cocktail_api_certificates

  certificate_arn         = aws_acm_certificate.cocktail_api_acm.arn
  validation_record_fqdns = [each.value.fqdn]
}

resource "aws_acm_certificate_validation" "cocktail_img_certificate_validations" {
  for_each = aws_route53_record.cocktail_img_certificates

  provider                = aws.virginia
  certificate_arn         = aws_acm_certificate.cocktail_img_acm.arn
  validation_record_fqdns = [each.value.fqdn]
}
