# Aplicación web que permite visualizar datos de la base de datos de finanzas públicas de 
# Eurostat (gov_10a_main) a través de un gráfico y una tabla, asi como descargar los mismos
# en un documento .pdf
#                   Elaborado por Kamal Romero (karomero@ucm.es)

library(shiny)
library(ggplot2)

shinyUI(pageWithSidebar(
  headerPanel("Datos de Finanzas Públicas (EUROSTAT)"),
  sidebarPanel(
    selectizeInput(
      "variable", "Variable",
      choices = c('Gasto Público'="TE",'Ingresos Públicos'="TR", "Balance Fiscal"="B9","Deuda/PIB"="GD")
    ),
    selectizeInput(
      "pais","País",
      choices=c('Grecia'="EL",'Alemania'="DE",'Bélgica'="BE",'Dinamarca'="DK",'Irlanda'="IE",'Italia'="IT",'Francia'="FR",'Países Bajos'="NL",'Portugal'="PT",'Austria'="AT",'Finlandia'="FI",'Suecia'="SE",'Reino Unido'="UK",
                "Bulgaria"="BG","Republica Checa" = "CZ", "Polonia" = "PL", "Rumanía" = "RO", "Hungría" ="HU",
                "Lituania" = "LT", "Letonia"="LV", "Estonia" ="EE")
      
    ),
    
    radioButtons('format', 'Formato del reporte', c('PDF'),
                 inline = TRUE),
    downloadButton('downloadReport')
    
),
  mainPanel(
    plotOutput("grafico"),
    tableOutput("tabla")
  )
))

