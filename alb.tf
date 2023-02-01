resource "aws_alb" "cocktail_alb" {
  name                       = "${var.r_prefix}-alb"
  security_groups            = [aws_security_group.cocktail_sg_alb.id]

  subnets                    = [
    "${aws_subnet.cocktail_public_subnet_1a.id}",
    "${aws_subnet.cocktail_public_subnet_1c.id}"
  ]

  internal                   = false
  enable_deletion_protection = false

  access_logs {
    bucket  = "${aws_s3_bucket.cocktail_alb_logs.bucket}"
  }
}

resource "aws_alb_target_group" "cocktail_alb_tg" {
  name                 = "${var.r_prefix}-alb-tg"
  port                 = 80
  depends_on           = [aws_alb.cocktail_alb]
  target_type          = "ip"
  protocol             = "HTTP"
  vpc_id               = "${aws_vpc.cocktail_vpc.id}"
  deregistration_delay = 15

  health_check {
    interval            = 30
    path                = "/health_check"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 2
    matcher             = 200
  }
}

resource "aws_alb_listener" "cocktail_alb_listener" {
  port              = "443"
  protocol          = "HTTPS"

  load_balancer_arn = "${aws_alb.cocktail_alb.arn}"

  certificate_arn   = "${aws_acm_certificate.cocktail_api_acm.arn}"

  default_action {
    target_group_arn = "${aws_alb_target_group.cocktail_alb_tg.arn}"
    type             = "forward"
  }

  depends_on = [
    aws_acm_certificate_validation.cocktail_api_certificate_validations
  ]
}

resource "aws_alb_listener_rule" "cocktail_alb_listener_rule" {
  depends_on         = [aws_alb_target_group.cocktail_alb_tg]
  listener_arn       = "${aws_alb_listener.cocktail_alb_listener.arn}"
  priority           = 100

  action {
    type             = "forward"
    target_group_arn = "${aws_alb_target_group.cocktail_alb_tg.arn}"
  }

  condition {
    path_pattern {
      values = ["/"]
    }
  }
}
