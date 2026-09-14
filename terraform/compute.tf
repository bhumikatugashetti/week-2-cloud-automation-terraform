data "aws_ami" "amazon_linux" {
  most_recent = true
  owners = ["137112412989"]

  filter {
    name = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }

  filter {
    name = "architecture"
    values = ["x86_64"]
  }

  filter {
    name = "root-device-type"
    values = ["ebs"]
  }
}

resource "aws_launch_template" "web" {
  name_prefix = "${var.project_name}-web-"
  image_id = data.aws_ami.amazon_linux.id
  instance_type = var.web_instance_type
  vpc_security_group_ids = [aws_security_group.web.id]

  iam_instance_profile { name = aws_iam_instance_profile.ec2.name }

  user_data = base64encode(templatefile("${path.module}/../scripts/web_userdata.sh", {
    internal_alb_dns = aws_lb.internal.dns_name
  }))

  metadata_options {
    http_endpoint = "enabled"
    http_tokens = "required"
  }

  monitoring { enabled = true }
}

resource "aws_autoscaling_group" "web" {
  name = "${var.project_name}-web-asg"
  min_size = var.web_min_size
  max_size = var.web_max_size
  desired_capacity = var.web_desired_capacity
  vpc_zone_identifier = [aws_subnet.public_a.id, aws_subnet.public_b.id]
  health_check_type = "ELB"

  launch_template {
    id = aws_launch_template.web.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.web.arn]

  tag {
    key = "Name"
    value = "${var.project_name}-web"
    propagate_at_launch = true
  }
}

resource "aws_launch_template" "app" {
  name_prefix = "${var.project_name}-app-"
  image_id = data.aws_ami.amazon_linux.id
  instance_type = var.app_instance_type
  vpc_security_group_ids = [aws_security_group.app.id]

  iam_instance_profile { name = aws_iam_instance_profile.ec2.name }

  user_data = filebase64("${path.module}/../scripts/app_userdata.sh")

  metadata_options {
    http_endpoint = "enabled"
    http_tokens = "required"
  }

  monitoring { enabled = true }
}

resource "aws_autoscaling_group" "app" {
  name = "${var.project_name}-app-asg"
  min_size = var.app_min_size
  max_size = var.app_max_size
  desired_capacity = var.app_desired_capacity
  vpc_zone_identifier = [aws_subnet.app_a.id, aws_subnet.app_b.id]
  health_check_type = "ELB"

  launch_template {
    id = aws_launch_template.app.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.app.arn]

  tag {
    key = "Name"
    value = "${var.project_name}-app"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_policy" "web_cpu" {
  name = "${var.project_name}-web-cpu"
  autoscaling_group_name = aws_autoscaling_group.web.name
  policy_type = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 60
  }
}

resource "aws_autoscaling_policy" "app_cpu" {
  name = "${var.project_name}-app-cpu"
  autoscaling_group_name = aws_autoscaling_group.app.name
  policy_type = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 60
  }
}
