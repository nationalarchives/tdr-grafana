{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Action":["logs:CreateLogStream", "logs:PutLogEvents"],
      "Resource": ["${cloudwatch_log_group}"]
    }
  ]
}
