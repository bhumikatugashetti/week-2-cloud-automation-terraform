resource "aws_lb" "public" {
  name = substr("${var.project_name}-public", 0, 32)
  internal = false
  load_balancer_type = "application"
  security_groups = [aws_security_group.public_alb.id]
  subnets = [aws_subnet.public_a.id, aws_subnet.public_b.id]
}

resource "aws_lb_target_group" "web" {
  name = substr("${var.project_name}-web-tg", 0, 32)
  port = 80
  protocol = "HTTP"
  vpc_id = aws_vpc.main.id

  health_check {
    enabled = true
    path = "/health"
    protocol = "HTTP"
    matcher = "200"
    interval = 30
    timeout = 5
    healthy_threshold = 2
    unhealthy_threshold = 3
  }
}

resource "aws_lb_listener" "public_http" {
  load_balancer_arn = aws_lb.public.arn
  port = 80
  protocol = "HTTP"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.web.arn
  }
}

resource "aws_lb" "internal" {
  name = substr("${var.project_name}-internal", 0, 32)
  internal = true
  load_balancer_type = "application"
  security_groups = [aws_security_group.internal_alb.id]
  subnets = [aws_subnet.app_a.id, aws_subnet.app_b.id]
}

resource "aws_lb_target_group" "app" {
  name = substr("${var.project_name}-app-tg", 0, 32)
  port = 5000
  protocol = "HTTP"
  vpc_id = aws_vpc.main.id

  health_check {
    enabled = true
    path = "/health"
    protocol = "HTTP"
    matcher = "200"
    interval = 30
    timeout = 5
    healthy_threshold = 2
    unhealthy_threshold = 3
  }
}

resource "aws_lb_listener" "internal_http" {
  load_balancer_arn = aws_lb.internal.arn
  port = 80
  protocol = "HTTP"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}
