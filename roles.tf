resource "aws_iam_policy" "lambda_bucket_policy" {
  name        = var.lambda_bucket_policy_name
  path        = "/"
  description = "Policy to create objects on S3 from lambda function"

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "s3:GetObject",
                "s3:PutObject"
            ],
            "Resource": "arn:aws:s3:::${var.mapper_bucket_name}/u/*",
            "Effect": "Allow"
        }
    ]
})
}


resource "aws_iam_role" "mapper_role" {
  name = var.mapper_role_name

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}
resource "aws_iam_role_policy_attachment" "mapper-policy-attach1" {
  role       = aws_iam_role.mapper_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
resource "aws_iam_role_policy_attachment" "mapper-policy-attach2" {
  role       = aws_iam_role.mapper_role.name
  policy_arn = aws_iam_policy.lambda_bucket_policy.arn
}


resource "aws_iam_role" "api_gateway_role" {
  name = var.api_gateway_role_name

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "apigateway.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}
resource "aws_iam_role_policy_attachment" "gateway-policy-attach" {
  role       = aws_iam_role.api_gateway_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonAPIGatewayPushToCloudWatchLogs"
}