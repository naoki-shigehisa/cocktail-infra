locals {
  s3_origin_id = "s3-origin-img.${var.domain_name}"
}

resource "aws_cloudfront_origin_access_identity" "cocktail_image_access_identity" {
  comment = "img.${var.domain_name}"
}

resource "aws_cloudfront_distribution" "cocktail_image_cloudfront" {
  origin {
    domain_name = "${aws_s3_bucket.cocktail_images.bucket_regional_domain_name}"
    origin_id   = "${local.s3_origin_id}"

    s3_origin_config {
      origin_access_identity = "${aws_cloudfront_origin_access_identity.cocktail_image_access_identity.cloudfront_access_identity_path}"
    }
  }

  aliases = ["img.${var.domain_name}"]

  enabled             = true
  is_ipv6_enabled     = true
  comment = "img.${var.domain_name}"
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "${local.s3_origin_id}"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  price_class = "PriceClass_200"

  viewer_certificate {
    acm_certificate_arn = "${aws_acm_certificate.cocktail_img_acm.arn}"
    ssl_support_method = "sni-only"
    minimum_protocol_version = "TLSv1"
  }
}
