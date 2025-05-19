###########################################
# Definicion Outputs ACM - Opcionales
###########################################

output "certificate_arns" {
  description = "ARNs de los certificados creados"
  value       = { for k, v in aws_acm_certificate.certificate : k => v.arn }
}

output "certificate_domains" {
  description = "Dominios principales de los certificados creados"
  value       = { for k, v in aws_acm_certificate.certificate : k => v.domain_name }
}

output "certificate_validation_options" {
  description = "Opciones de validación para los certificados creados"
  value       = { for k, v in aws_acm_certificate.certificate : k => v.domain_validation_options }
}

output "certificate_status" {
  description = "Estado de los certificados creados"
  value       = { for k, v in aws_acm_certificate.certificate : k => v.status }
}

output "dns_validation_records" {
  description = "Registros DNS necesarios para la validación (solo para certificados con validación DNS)"
  value = {
    for k, v in aws_acm_certificate.certificate : k => [
      for dvo in v.domain_validation_options : {
        domain = dvo.domain_name
        name   = dvo.resource_record_name
        type   = dvo.resource_record_type
        value  = dvo.resource_record_value
      } if v.validation_method == "DNS"
    ]
  }
}
