# Data aws_caller_identity
data "aws_caller_identity" "current" {
  provider = aws.project
}

# Data validacion region
data "aws_region" "current" {
  provider = aws.project
}
