resource "aws_cloudwatch_log_group" "generate_shortener_url" {
  name            = "/aws/lambda/generateShortenerUrl"
  log_group_class = "STANDARD"
}

resource "aws_cloudwatch_log_group" "redirect" {
  name            = "/aws/lambda/RedirectUrlShotener"
  log_group_class = "STANDARD"
}

resource "aws_lambda_function" "generate_shortener_url" {
  function_name    = "generateShortenerUrl"
  role             = aws_iam_role.generate_shortener_url.arn
  handler          = "com.org.createUrlShortner.Main::handleRequest"
  runtime          = "java17"
  filename         = "${path.module}/../CreateUrlLambda/target/CreateUrlLambda-1.0-SNAPSHOT.jar"
  source_code_hash = filebase64sha256("${path.module}/../CreateUrlLambda/target/CreateUrlLambda-1.0-SNAPSHOT.jar")
  memory_size      = 512
  timeout          = 15
  architectures    = ["x86_64"]
  package_type     = "Zip"

  ephemeral_storage {
    size = 512
  }

  logging_config {
    log_format = "Text"
    log_group  = aws_cloudwatch_log_group.generate_shortener_url.name
  }

  environment {
    variables = {
      BUCKET_NAME = local.bucket_name
    }
  }

  tracing_config {
    mode = "PassThrough"
  }

}

resource "aws_lambda_function" "redirect" {
  function_name    = "RedirectUrlShotener"
  role             = aws_iam_role.redirect.arn
  handler          = "com.org.redirectURLShotener.Main::handleRequest"
  runtime          = "java17"
  filename         = "${path.module}/../RedirectUrlShotener/target/RedirectUrlShotener-1.0-SNAPSHOT.jar"
  source_code_hash = filebase64sha256("${path.module}/../RedirectUrlShotener/target/RedirectUrlShotener-1.0-SNAPSHOT.jar")
  memory_size      = 512
  timeout          = 15
  architectures    = ["x86_64"]
  package_type     = "Zip"

  ephemeral_storage {
    size = 512
  }

  logging_config {
    log_format = "Text"
    log_group  = aws_cloudwatch_log_group.redirect.name
  }

  environment {
    variables = {
      BUCKET_NAME = local.bucket_name
    }
  }

  tracing_config {
    mode = "PassThrough"
  }

}

resource "aws_lambda_permission" "generate_shortener_url" {
  statement_id  = "acb13585-8df8-5ee9-8ef8-ccb3cc658721"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.generate_shortener_url.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.url_shortener.execution_arn}/*/*/create"
}

resource "aws_lambda_permission" "redirect" {
  statement_id  = "f5aafa68-7442-529a-94d8-1f64896cc37c"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.redirect.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.url_shortener.execution_arn}/*/*/{urlCode}"
}
