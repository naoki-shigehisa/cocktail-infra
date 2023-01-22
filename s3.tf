resource "aws_s3_bucket" "cocktail_alb_logs" {
  bucket = "${var.r_prefix}-20220115-alb-logs"
}
