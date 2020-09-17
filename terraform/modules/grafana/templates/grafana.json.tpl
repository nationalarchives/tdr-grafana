[
  {
    "name": "tdr-grafana",
    "image": "${app_image}",
    "cpu": 0,
    "secrets": [
      {
        "valueFrom": "${admin_user}",
        "name": "GF_SECURITY_ADMIN_USER"
      },
      {
        "valueFrom": "${admin_user_password}",
        "name": "GF_SECURITY_ADMIN_PASSWORD"
      }
    ],
    "environment": [],
    "networkMode": "awsvpc",
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "/ecs/grafana-${app_environment}",
        "awslogs-region": "${aws_region}",
        "awslogs-stream-prefix": "ecs"
      }
    },
    "portMappings": [
      {
        "containerPort": 3000,
        "hostPort": 3000
      }
    ]
  }
]
