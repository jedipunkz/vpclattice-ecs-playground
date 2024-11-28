resource "aws_iam_role" "ecs_infrastructure" {
  name = "vpclattice-ecs-playground"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : "sts:AssumeRole",
        "Principal" : {
          "Service" : "ecs.amazonaws.com"
        },
        "Effect" : "Allow",
        "Sid" : "AllowAccessToECSForInfrastructureManagement"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "vpclattice" {
  role       = aws_iam_role.ecs_infrastructure.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonECSInfrastructureRolePolicyForVpcLattice"
}

resource "aws_iam_role_policy_attachment" "serviceconnecttransportlayersecurity" {
  role       = aws_iam_role.ecs_infrastructure.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSInfrastructureRolePolicyForServiceConnectTransportLayerSecurity"
}

resource "aws_iam_role_policy_attachment" "volumes" {
  role       = aws_iam_role.ecs_infrastructure.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSInfrastructureRolePolicyForVolumes"
}

