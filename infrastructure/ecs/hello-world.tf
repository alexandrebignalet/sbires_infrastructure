resource "aws_ecs_task_definition" "hello_world" {
  family                   = "hello-world"
  requires_compatibilities = ["EC2"]
  network_mode             = "bridge"
  cpu                      = "256"
  memory                   = "256"

  container_definitions = <<EOF
[
  {
    "command": ["-listen=:8080", "-text=hello"],
    "essential": true,
    "image": "hashicorp/http-echo",
    "name": "server",
    "portMappings": [
      { "containerPort": 8080 }
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "${aws_cloudwatch_log_group.log_group.name}",
        "awslogs-region": "${var.aws_region}",
        "awslogs-stream-prefix": "${var.environment}"
      }
    }
  }
]
EOF
}

resource "aws_cloudwatch_log_group" "log_group" {
  name = "hello-world-${var.environment}"

  tags {
    Application = "skilbill"
    Environment = "${var.environment}"
  }
}
