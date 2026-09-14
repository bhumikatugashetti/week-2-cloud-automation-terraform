resource "aws_security_group" "public_alb" {
  name = "${var.project_name}-public-alb-sg"
  description = "Allow public HTTP to the public load balancer."
  vpc_id = aws_vpc.main.id

  ingress {
    description = "HTTP from the Internet"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "web" {
  name = "${var.project_name}-web-sg"
  description = "Web tier accepts traffic only from the public ALB."
  vpc_id = aws_vpc.main.id

  ingress {
    description = "HTTP from public ALB"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    security_groups = [aws_security_group.public_alb.id]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "internal_alb" {
  name = "${var.project_name}-internal-alb-sg"
  description = "Internal ALB accepts HTTP only from the web tier."
  vpc_id = aws_vpc.main.id

  ingress {
    description = "HTTP from web tier"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    security_groups = [aws_security_group.web.id]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "app" {
  name = "${var.project_name}-app-sg"
  description = "Application tier accepts traffic only from internal ALB."
  vpc_id = aws_vpc.main.id

  ingress {
    description = "Application HTTP from internal ALB"
    from_port = 5000
    to_port = 5000
    protocol = "tcp"
    security_groups = [aws_security_group.internal_alb.id]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "db" {
  name = "${var.project_name}-db-sg"
  description = "PostgreSQL only from application tier."
  vpc_id = aws_vpc.main.id

  ingress {
    description = "PostgreSQL from application tier"
    from_port = 5432
    to_port = 5432
    protocol = "tcp"
    security_groups = [aws_security_group.app.id]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
