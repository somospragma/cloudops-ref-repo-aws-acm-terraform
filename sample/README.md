# Ejemplo de implementación del módulo AWS Certificate Manager

Este directorio contiene un ejemplo completo de cómo implementar el módulo de AWS Certificate Manager (ACM) para crear y gestionar certificados SSL/TLS.

## Estructura de archivos

```
sample/
├── data.tf              # Data sources utilizados en el ejemplo
├── main.tf              # Implementación del módulo
├── outputs.tf           # Outputs del ejemplo
├── providers.tf         # Configuración del proveedor AWS
├── README.md            # Este archivo
├── terraform.auto.tfvars.sample # Variables de ejemplo (renombrar a terraform.auto.tfvars para usar)
└── variables.tf         # Definición de variables
```

## Requisitos previos

1. [Terraform](https://www.terraform.io/downloads.html) (versión >= 1.0.0)
2. [AWS CLI](https://aws.amazon.com/cli/) configurado con las credenciales adecuadas
3. Permisos IAM para crear y gestionar recursos de AWS Certificate Manager
4. Acceso para crear registros DNS en los dominios para los que se solicitan certificados (para validación DNS)

## Cómo usar este ejemplo

1. **Preparar las variables**:
   - Copie el archivo `terraform.auto.tfvars.sample` a `terraform.auto.tfvars`
   - Revise y modifique el archivo `terraform.auto.tfvars` según sus necesidades
   - Asegúrese de actualizar los valores de `profile`, `aws_region`, `client`, `project`, `environment` y `common_tags`
   - Actualice los dominios y configuraciones de certificados según su entorno

2. **Inicializar Terraform**:
   ```bash
   terraform init
   ```

3. **Verificar el plan de ejecución**:
   ```bash
   terraform plan
   ```

4. **Aplicar la configuración**:
   ```bash
   terraform apply
   ```

5. **Verificar los recursos creados**:
   - Compruebe los certificados creados en la consola de AWS
   - Revise los outputs de Terraform para obtener la información de validación

## Escenarios incluidos

Este ejemplo demuestra diferentes escenarios de validación de certificados:

### Escenario 1: Validación DNS sin espera (recomendado)

```hcl
"portal" = {
  domain_name               = "portal.example.com"
  subject_alternative_names = []
  validation_method         = "DNS"
  key_algorithm             = "EC_prime256v1"
  # No se especifica wait_for_validation (por defecto es false)
}
```

**Flujo de trabajo recomendado:**
1. Crear el certificado con Terraform
2. Obtener la información de validación de los outputs (`dns_validation_records`)
3. Crear manualmente los registros DNS en su proveedor DNS
4. Esperar a que AWS valide el certificado (fuera de Terraform)

Este es el enfoque más práctico y flexible, especialmente cuando:
- Los registros DNS son administrados por otro equipo
- La zona DNS está en otra cuenta o proveedor
- Se requiere aprobación para cambios en DNS

### Escenario 2: Validación por EMAIL

```hcl
"web" = {
  domain_name               = "www.example.com"
  subject_alternative_names = ["example.com"]
  validation_method         = "EMAIL"
  key_algorithm             = "EC_prime256v1"
}
```

**Flujo de trabajo:**
1. Crear el certificado con Terraform
2. AWS envía correos electrónicos a las direcciones de contacto del dominio
3. Hacer clic en los enlaces de validación recibidos por correo
4. El certificado se valida (fuera de Terraform)

Este enfoque es útil cuando:
- No tienes acceso para modificar los registros DNS
- Tienes acceso a las direcciones de correo electrónico del dominio

**Nota importante:** Para la validación por EMAIL, el dominio debe tener configurados registros MX válidos y capacidad para recibir correos en al menos una de estas direcciones:
- admin@dominio.com
- administrator@dominio.com
- hostmaster@dominio.com
- postmaster@dominio.com
- webmaster@dominio.com

### Escenario 3: Validación DNS con espera automática (avanzado)

```hcl
"api" = {
  domain_name               = "api.example.com"
  subject_alternative_names = ["api-dev.example.com", "api-test.example.com"]
  validation_method         = "DNS"
  key_algorithm             = "RSA_2048"
  wait_for_validation       = true
  # No se especifica validation_record_fqdns
}
```

**Flujo de trabajo:**
1. Crear el certificado con Terraform
2. Terraform esperará indefinidamente hasta que AWS detecte que los registros DNS han sido validados
3. Debes crear los registros DNS manualmente o con otro recurso de Terraform antes de que finalice el timeout

Este enfoque es útil cuando:
- Estás usando Route 53 y puedes crear los registros DNS en el mismo plan
- Tienes un proceso automatizado para crear los registros DNS

### Escenario 4: Validación DNS con espera específica (avanzado)

```hcl
"admin" = {
  domain_name               = "admin.example.com"
  subject_alternative_names = ["admin-dev.example.com"]
  validation_method         = "DNS"
  key_algorithm             = "RSA_2048"
  wait_for_validation       = true
  validation_record_fqdns   = [
    "_a79865eb4cd1fd251e19a1b347d3d8f1.admin.example.com.",
    "_a79865eb4cd1fd251e19a1b347d3d8f1.admin-dev.example.com."
  ]
}
```

**Nota importante:** Este escenario requiere un proceso de dos pasos:
1. Primero crear el certificado sin esperar validación
2. Obtener los valores de validación y crear los registros DNS
3. Actualizar la configuración para esperar la validación con los FQDNs específicos

Este enfoque es útil cuando:
- Necesitas un control preciso sobre qué registros DNS se están validando
- Los registros DNS se crean fuera de Terraform

## Flujos de trabajo recomendados

### Flujo de trabajo para validación DNS

1. Crea los certificados sin esperar validación:
   ```bash
   terraform apply
   ```

2. Obtén la información de validación:
   ```bash
   terraform output dns_validation_records
   ```

3. Crea los registros DNS en tu proveedor DNS:
   - Tipo: CNAME
   - Nombre: El valor de `name` (sin el dominio base)
   - Valor: El valor de `value`
   - TTL: 300 segundos (recomendado)

4. Espera a que AWS valide el certificado (puede tardar desde minutos hasta horas)

5. Verifica el estado del certificado en la consola de AWS o con AWS CLI:
   ```bash
   aws acm describe-certificate --certificate-arn <certificate_arn>
   ```

### Flujo de trabajo para validación EMAIL

1. Crea los certificados:
   ```bash
   terraform apply
   ```

2. Verifica las siguientes direcciones de correo electrónico asociadas con el dominio:
   - admin@example.com
   - administrator@example.com
   - hostmaster@example.com
   - postmaster@example.com
   - webmaster@example.com

3. Haz clic en el enlace de validación en el correo electrónico recibido

4. Verifica el estado del certificado en la consola de AWS o con AWS CLI:
   ```bash
   aws acm describe-certificate --certificate-arn <certificate_arn>
   ```

## Integración con otros servicios AWS

Una vez validados, los certificados de ACM pueden utilizarse con varios servicios de AWS:

### Con CloudFront

```hcl
resource "aws_cloudfront_distribution" "distribution" {
  # ... otras configuraciones
  
  viewer_certificate {
    acm_certificate_arn = module.acm.certificate_arns["web"]
    ssl_support_method  = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }
}
```

### Con Application Load Balancer

```hcl
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.example.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = module.acm.certificate_arns["api"]
  
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.example.arn
  }
}
```

### Con API Gateway

```hcl
resource "aws_api_gateway_domain_name" "example" {
  domain_name              = "api.example.com"
  regional_certificate_arn = module.acm.certificate_arns["api"]
  
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}
```

## Solución de problemas comunes

### Problemas con validación DNS

- **Problema**: Los registros DNS no se validan después de varias horas
  **Solución**: Verifique que los registros DNS se hayan creado correctamente. Utilice herramientas como `dig` o `nslookup` para comprobar la propagación de los registros DNS.

- **Problema**: Error "No se puede validar el certificado"
  **Solución**: Asegúrese de que los registros CNAME se hayan creado exactamente como se especifica en los outputs de Terraform, sin modificar los valores.

### Problemas con validación EMAIL

- **Problema**: No se reciben correos electrónicos de validación
  **Solución**: Verifique que el dominio tenga configurados registros MX válidos y que las direcciones de correo electrónico estén activas y puedan recibir correos.

- **Problema**: Los enlaces de validación han expirado
  **Solución**: Elimine el certificado y cree uno nuevo. Los enlaces de validación tienen un tiempo de expiración limitado.

## Limpieza

Para eliminar todos los recursos creados:

```bash
terraform destroy
```

**Nota importante:** Los certificados de ACM que están en uso por otros servicios de AWS no pueden ser eliminados hasta que se eliminen esos servicios o se desvinculen de los certificados. Si intenta eliminar un certificado en uso, recibirá un error. Primero debe eliminar o actualizar los recursos que utilizan el certificado.
