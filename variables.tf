###########################################
# Variables Globales
###########################################

variable "client" {
  description = "Identificador del cliente"
  type        = string
  
  validation {
    condition     = length(var.client) > 0
    error_message = "El valor de client no puede estar vacío."
  }
}

variable "project" {
  description = "Nombre del proyecto asociado a los certificados"
  type        = string
  
  validation {
    condition     = length(var.project) > 0
    error_message = "El valor de project no puede estar vacío."
  }
}

variable "environment" {
  description = "Entorno en el que se desplegarán los certificados (dev, qa, pdn)"
  type        = string
  
  validation {
    condition     = contains(["dev", "qa", "pdn"], var.environment)
    error_message = "El entorno debe ser uno de: dev, qa, pdn."
  }
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
  
  validation {
    condition = alltrue([
      for k, v in var.certificates_config : 
      contains(["DNS", "EMAIL"], v.validation_method)
    ])
    error_message = "El método de validación debe ser 'DNS' o 'EMAIL'."
  }
  
  validation {
    condition = alltrue([
      for k, v in var.certificates_config : 
      contains(["RSA_1024", "RSA_2048", "RSA_4096", "EC_prime256v1", "EC_secp384r1"], v.key_algorithm)
    ])
    error_message = "El algoritmo de clave debe ser uno de: 'RSA_1024', 'RSA_2048', 'RSA_4096', 'EC_prime256v1', 'EC_secp384r1'."
  }
}

