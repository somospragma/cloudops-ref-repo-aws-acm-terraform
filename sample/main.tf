###########################################
# Definicion modulo ACM
###########################################

module "acm" {
  source = "../"
  providers = {
    aws.project = aws.principal
  }

  # Definicion variables Globales
  client      = var.client
  project     = var.project
  environment = var.environment

  # Definicion certificates_config
  certificates_config = var.certificates_config
}
