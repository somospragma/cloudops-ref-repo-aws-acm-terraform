###########################################
# Variables Globales
###########################################
variable "aws_region" {
  description = "Región de AWS donde se desplegarán los recursos"
  type        = string
}

# Opcional para ejecutar el modulo localmente - Validar providers.tf 
variable "profile" {
  description = "Perfil de AWS a utilizar"
  type        = string
  default     = "default"
}

variable "client" {
  description = "Identificador del cliente"
  type        = string
}

variable "project" {
  description = "Nombre del proyecto asociado a los certificados"
  type        = string
}

variable "environment" {
  description = "Entorno en el que se desplegarán los certificados (dev, qa, pdn)"
  type        = string
  
  validation {
    condition     = contains(["dev", "qa", "pdn"], var.environment)
    error_message = "El entorno debe ser uno de: dev, qa, pdn."
  }
}

variable "common_tags" {
  type = map(string)
  description = "Common tags to be applied to the resources"
}

###########################################
# Variables Modulo ACM
###########################################
variable "certificates_config" {
  description = "Configuración de certificados en AWS Certificate Manager"
  type = map(object({
    domain_name               = string
    subject_alternative_names = optional(list(string), [])
    validation_method         = string
    key_algorithm             = optional(string, "RSA_2048")
    wait_for_validation       = optional(bool, false)
    validation_record_fqdns   = optional(list(string), null)
    additional_tags           = optional(map(string), {})
  }))
}
