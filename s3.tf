resource "aws_s3_bucket" "cocktail_alb_logs" {
  bucket = "${var.r_prefix}-20220115-alb-logs"
}

resource "aws_s3_bucket" "cocktail_images" {
  bucket = "${var.r_prefix}-images-20230211"
}

resource "aws_s3_bucket_acl" "cocktail_images_acl" {
  bucket = aws_s3_bucket.cocktail_images.id
  acl    = "private"
}

resource "aws_s3_bucket_policy" "cocktail_images_policy" {
  bucket = "${aws_s3_bucket.cocktail_images.id}"
  policy = "${data.aws_iam_policy_document.cocktail_images_policy_document.json}"
}

data "aws_iam_policy_document" "cocktail_images_policy_document" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.cocktail_images.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = ["${aws_cloudfront_origin_access_identity.cocktail_image_access_identity.iam_arn}"]
    }
  }
}
