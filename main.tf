locals {
  # Generar nombres estandarizados para los certificados
  certificate_names = {
    for k, v in var.certificates_config : k => "${var.client}-${var.project}-${var.environment}-acm-${k}"
  }
}

###########################################
# Rescuros Certificado ACM
###########################################
resource "aws_acm_certificate" "certificate" {
  provider = aws.project
  for_each = var.certificates_config

  domain_name               = each.value.domain_name
  subject_alternative_names = each.value.subject_alternative_names
  validation_method         = each.value.validation_method
  key_algorithm             = each.value.key_algorithm

  # Importante para permitir la renovación de certificados
  lifecycle {
    create_before_destroy = true
  }
  tags = merge(
    {
      Name = local.certificate_names[each.key]
    },
    each.value.additional_tags
  )
}

#################################################
# Rescuros Validacion Certificado ACM (Opcional)
#################################################
# Se crea solo cuando wait_for_validation = true
resource "aws_acm_certificate_validation" "validation" {
  provider = aws.project
  for_each = {
    for k, v in var.certificates_config : k => v
    if v.wait_for_validation == true
  }

  certificate_arn         = aws_acm_certificate.certificate[each.key].arn
  validation_record_fqdns = each.value.validation_record_fqdns
}
