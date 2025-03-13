resource "aws_organizations_policy" "restrict_regions" {
  name        = "RestrictNonEURegions"
  description = "Allow resources only in EU regions"
  type        = "SERVICE_CONTROL_POLICY"

  content = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Sid": "DenyNonEURegions",
        "Effect": "Deny",
        "Action": "*",
        "Resource": "*",
        "Condition": {
          "StringNotEqualsIfExists": {
            "aws:RequestedRegion": [
              "eu-west-1",
              "eu-west-2",
              "eu-west-3",
              "eu-central-1",
              "eu-north-1",
              "eu-south-1",
              "eu-south-2"
            ]
          }
        }
      }
    ]
  })
}
