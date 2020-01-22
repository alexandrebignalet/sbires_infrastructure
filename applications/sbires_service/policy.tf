# ----------------------------------------------------—-----------------
# If any permissions are needed for this service
# Use the following resource to attach them to the task role
# ----------------------------------------------------—-----------------
resource "aws_iam_role_policy" "service_policy" {
  name = "sbires-service-policy"
  role = "${module.ecs_service.task_role}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "cloudwatch:PutMetricData"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}
