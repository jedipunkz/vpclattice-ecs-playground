resource "aws_ecs_cluster" "main" {
  name = "vpclattice-ecs-playground"
}

resource "aws_ecs_service" "main" {
  name            = "vpclattice-ecs-playground"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.main.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    assign_public_ip = true
    subnets          = module.vpc.private_subnets
    security_groups  = [aws_security_group.ecs_service.id]
  }

  vpc_lattice_configurations {
    role_arn         = aws_iam_role.ecs_infrastructure.arn
    target_group_arn = aws_vpclattice_target_group.main.arn
    port_name        = "web-80-tcp"
  }
}

resource "aws_ecs_task_definition" "main" {
  container_definitions = jsonencode([{
    essential = true
    image     = "public.ecr.aws/ecs-sample-image/amazon-ecs-sample:latest"
    name      = "webserver"
    portMappings = [{
      appProtocol   = "http"
      containerPort = 80
      hostPort      = 80
      name          = "web-80-tcp"
      protocol      = "tcp"
    }]
  }])
  cpu                      = jsonencode(1024)
  family                   = "webserver"
  memory                   = jsonencode(2048)
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
}

