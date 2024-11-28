resource "aws_vpclattice_target_group" "main" {
  name = "vpclattice-ecs-playground"
  type = "IP"

  config {
    ip_address_type  = "IPV4"
    vpc_identifier   = module.vpc.vpc_id
    port             = 80
    protocol         = "HTTP"
    protocol_version = "HTTP1"
    health_check {
      enabled                       = true
      health_check_interval_seconds = 30
      health_check_timeout_seconds  = 5
      healthy_threshold_count       = 5
      path                          = "/"
      protocol                      = "HTTP"
      protocol_version              = "HTTP1"
      unhealthy_threshold_count     = 2
      matcher {
        value = jsonencode(200)
      }
    }
  }
}

resource "aws_vpclattice_listener" "main" {
  name               = "http-80"
  port               = 80
  protocol           = "HTTP"
  service_arn        = aws_vpclattice_service.main.arn
  service_identifier = aws_vpclattice_service.main.id
  default_action {
    forward {
      target_groups {
        target_group_identifier = aws_vpclattice_target_group.main.id
        weight                  = 1
      }
    }
  }
}

resource "aws_vpclattice_service" "main" {
  name      = "vpclattice-ecs-playground"
  auth_type = "NONE"
}

resource "aws_vpclattice_service_network" "main" {
  auth_type = "NONE"
  name      = "vpclattice-ecs-playground"
}

resource "aws_vpclattice_service_network_service_association" "service_association" {
  service_network_identifier = aws_vpclattice_service_network.main.id
  service_identifier         = aws_vpclattice_service.main.id
}

resource "aws_vpclattice_service_network_vpc_association" "vpc_association" {
  security_group_ids         = [aws_security_group.lattice_service_network.id]
  service_network_identifier = aws_vpclattice_service_network.main.id
  vpc_identifier             = module.vpc.vpc_id
}

