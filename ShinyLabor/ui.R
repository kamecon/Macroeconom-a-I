

shinyUI(pageWithSidebar(
  headerPanel("Datos de Empleo (EUROSTAT)"),
  sidebarPanel(
    selectizeInput(
      "concepto", "Concepto",
                choices = c('Paro'="une_rt_a",'Empleo y actividad'="lfsi_emp_a",'Paro de larga duración'="une_ltu_a",
                            'Nivel de educación'="lfsi_educ_a",'Empleo temporal'="lfsi_pt_a")
                ),
    selectizeInput(
      "pais","País",
                choices=c('Grecia'="EL",'Alemania'="DE",'Bélgica'="BE",'Dinamarca'="DK",'Irlanda'="IE",'Italia'="IT",'Francia'="FR",'Países Bajos'="NL",'Portugal'="PT",'Austria'="AT",'Finlandia'="FI",'Suecia'="SE",'Reino Unido'="UK")
                ),
    selectizeInput(
      "sexo", "Sexo",
                choices=c('Total'="T", 'Mujeres'="F",'Hombres'="M")
                ),
    selectizeInput(
      "unidad", "Unidad",
                choices=c('% Pob. Activa'="PC_ACT",'% Población'="PC_POP",'% Paro'="PC_UNE",'% Empleo'="PC_EMP")
                ),
    selectizeInput(
      "edad", "Edad",
                   choices=c('Total'="TOTAL",'Entre 15 y 64'="Y15-64",'Entre 15 y 74'="Y15-74")
                   ),
    selectizeInput(
      "indicador", "Indicador",
      choices=c('Largo plazo'="LTU",'Muy largo plazo'="VLTU","UEMP","NSEE_AV",'Empleo'="EMP_LFS",'Población activa'="ACT"),
      multiple = TRUE, options = list(maxItems = 2)
    ),
    selectizeInput(
      "estacion", "Ajuste Estacional",
      choices=c("TOTAL","Y15-64"),
      multiple = TRUE, options = list(maxItems = 2)
    ),
    selectizeInput(
      "educacion", "Nivel de Educación",
      choices=c('Primaria'="ED0-2",'Secundaria'="ED3_4",'Superior'="ED5-8"),
      multiple = TRUE, options = list(maxItems = 2)
    ),
    selectizeInput(
      "worktime", "Tiempo de trabajo",
      choices=c('Temporal'="TEMP",'Media jornada'="PT"),
      multiple = TRUE, options = list(maxItems = 2)
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

