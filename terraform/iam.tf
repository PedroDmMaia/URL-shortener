resource "aws_iam_role" "generate_shortener_url" {
  name                 = "PowerUserRole"
  description          = "Power user role for lambda.amazonaws.com"
  max_session_duration = 3600

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })

}

resource "aws_iam_role" "redirect" {
  name                 = "PowerUser-lambda-1"
  description          = "Power user role for lambda.amazonaws.com"
  max_session_duration = 3600

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })

}

resource "aws_iam_role_policy_attachment" "generate_basic_execution" {
  role       = aws_iam_role.generate_shortener_url.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "redirect_basic_execution" {
  role       = aws_iam_role.redirect.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "generate_s3" {
  name = "write-url-shortener-objects"
  role = aws_iam_role.generate_shortener_url.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid      = "WriteUrlObjects"
      Effect   = "Allow"
      Action   = "s3:PutObject"
      Resource = "arn:aws:s3:::${local.bucket_name}/*"
    }]
  })
}

resource "aws_iam_role_policy" "redirect_s3" {
  name = "read-url-shortener-objects"
  role = aws_iam_role.redirect.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid      = "ReadUrlObjects"
      Effect   = "Allow"
      Action   = "s3:GetObject"
      Resource = "arn:aws:s3:::${local.bucket_name}/*"
    }]
  })
}
