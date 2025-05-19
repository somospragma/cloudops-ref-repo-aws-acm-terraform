#######################################################
# Definicion providers AWS
#######################################################
provider "aws" {
  alias   = "principal"
  region  = var.aws_region
  # Se utilizar para ejecutar localmente
  profile = var.profile
  
  # Si se va asumir un rol especifico
  # assume_role {
  #   role_arn = var.deploy_role_arn
  # }

  # Definicion Tags Transversales
  default_tags {
   tags = var.common_tags
  }
}

#######################################################
# Definicion Terraform
#######################################################
terraform {
  required_version = ">= 1.10.0"
  required_providers {
    aws = {
      configuration_aliases = [aws.principal]
      source                = "hashicorp/aws"
      version               = ">=4.31.0"
    }
  }
}