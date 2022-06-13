{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Action": "sts:AssumeRole",
      "Resource": [
        "arn:aws:iam::${intg_account_id}:role/TDRGrafanaMonitoringRoleIntg",
        "arn:aws:iam::${prod_account_id}:role/TDRGrafanaMonitoringRoleProd",
        "arn:aws:iam::${staging_account_id}:role/TDRGrafanaMonitoringRoleStaging"]
    }
  ]
}
