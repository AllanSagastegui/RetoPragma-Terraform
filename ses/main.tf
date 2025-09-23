resource "aws_ses_template" "notificacion_credito" {
  name = "NotificacionCredito"

  subject = "Estado de tu solicitud de crédito: {{status}}"

  text = <<EOT
            Hola {{name}} {{lastname}},

            Tu solicitud con ID {{idLoanApplication}} ha sido procesada.
            Estado: {{status}}
            Monto: S/{{amount}}
            Plazo: {{term}} meses
            Tipo de préstamo: {{loanType}}

            Gracias por confiar en Creditya.
        EOT

  html = file("${path.module}/notificacion_credito.html")
} 

resource "aws_ses_template" "reporte_diario" {
  name = "Reporte-Diario-Solicitudes"

  subject = "Reporte diario de solicitudes... {{reportDate}}"

  text = <<EOT
            Reporte del día {{reportDate}}:

            - Aprobadas: {{approvedCount}}
            - Rechazadas: {{rejectedCount}}
            - Total: {{totalCount}}
            - Dinero prestado: S/{{moneySum}}

            Generado automáticamente por Creditya.
        EOT

  html = file("${path.module}/reporte_diario.html")
}

resource "aws_ses_email_identity" "ses_email_identity_1" { 
  email = "allxn.sxh@gmail.com" 
}

resource "aws_ses_email_identity" "ses_email_identity_2" { 
  email = "sagasteguiherradaa@gmail.com" 
}

resource "aws_ses_email_identity" "ses_email_identity_3" { 
  email = "allansagasteguih@gmail.com" 
}