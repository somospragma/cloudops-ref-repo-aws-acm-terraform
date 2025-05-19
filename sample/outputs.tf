###########################################
# Definicion Outputs ACM - Opcionales
###########################################

output "certificate_arns" {
  description = "ARNs de los certificados creados"
  value       = module.acm.certificate_arns
}

output "certificate_domains" {
  description = "Dominios principales de los certificados creados"
  value       = module.acm.certificate_domains
}

output "certificate_validation_options" {
  description = "Opciones de validación para los certificados creados"
  value       = module.acm.certificate_validation_options
}

output "dns_validation_records" {
  description = "Registros DNS necesarios para la validación (solo para certificados con validación DNS)"
  value       = module.acm.dns_validation_records
}

output "validation_instructions" {
  description = "Instrucciones para validar los certificados"
  value = <<-EOT
    ## Instrucciones para validar certificados

    ### Para certificados con validación DNS:
    1. Cree los siguientes registros DNS en su proveedor DNS:
       ${jsonencode(module.acm.dns_validation_records)}

    2. Espere a que AWS valide el certificado (puede tardar desde minutos hasta horas)

    3. Verifique el estado del certificado en la consola de AWS o con AWS CLI:
       ```
       aws acm describe-certificate --certificate-arn <certificate_arn>
       ```

    ### Para certificados con validación EMAIL:
    1. Revise las siguientes direcciones de correo electrónico asociadas con el dominio:
       - admin@example.com
       - administrator@example.com
       - hostmaster@example.com
       - postmaster@example.com
       - webmaster@example.com

    2. Haga clic en el enlace de validación en el correo electrónico recibido
  EOT
}
