resource "aws_ecs_cluster" "cocktail_cluster" {
  name = "${var.r_prefix}-cluster"
}

resource "aws_ecs_task_definition" "cocktail_api_nginx" {
  family                   = "cocktail-api"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc" # Fargateを使う場合は「awsvpc」で固定
  task_role_arn            = "arn:aws:iam::${var.aws_account_id}:role/ecsTaskExecutionRole"
  execution_role_arn       = "arn:aws:iam::${var.aws_account_id}:role/ecsTaskExecutionRole"
  cpu                      = 512
  memory                   = 1024
  container_definitions    = "${file("./task-definitions/app-nginx.json")}"
}

resource "aws_ecs_service" "cocktail_service" {
  cluster                            = "${aws_ecs_cluster.cocktail_cluster.id}"
  launch_type                        = "FARGATE"
  deployment_minimum_healthy_percent = 100
  deployment_maximum_percent         = 200
  name                               = "cocktail-service"
  task_definition                    = "${aws_ecs_task_definition.cocktail_api_nginx.arn}"
  desired_count                      = 1 # 常に1つのタスクが稼働する状態にする

  lifecycle {
    ignore_changes = [desired_count, task_definition]
  }

  load_balancer {
    target_group_arn = "${aws_alb_target_group.cocktail_alb_tg.arn}"
    container_name   = "nginx"
    container_port   = 80
  }

  network_configuration {
    subnets          = [
      aws_subnet.cocktail_public_subnet_1a.id,
      aws_subnet.cocktail_public_subnet_1c.id
    ]
    security_groups  = [
      aws_security_group.cocktail_sg_app.id,
      aws_security_group.cocktail_sg_db.id
    ]
    assign_public_ip = "true"
  }
}
