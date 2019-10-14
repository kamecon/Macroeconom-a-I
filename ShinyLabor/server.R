# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#


# PACKAGES <- c("eurostat","ggplot2","countrycode","tidyr","plyr","dplyr","knitr","quantmod")
# #  Install packages
# inst <- match(PACKAGES, .packages(all=TRUE))
# need <- which(is.na(inst))
# if (length(need) > 0) install.packages(PACKAGES[need])
# 
# # Load packages
# lapply(PACKAGES, require, character.only=T)

# euro2 <- function(concepto="une_rt_a",
#                   country="EL",
#                   sexo="T",
#                   unidad="PC_ACT",
#                   edad="TOTAL",
#                   indicador=NULL,
#                   estacion=NULL,
#                   worktime=NULL){
  
  
euro2 <- function(concepto,
                    country,
                    sexo,
                    unidad,
                    edad,
                    indicador=NULL,
                    estacion=NULL,
                    worktime=NULL,
                    educacion=NULL){
  
  #Limpiar cach?
  clean_eurostat_cache()
  
  #Dato a buscar
  dat <- get_eurostat(concepto, time_format = "raw")
  
  # Extract the information on country in question. (First two character in region string mark the country)
  dat$cntry <- substr(dat$geo, 1,2)
  
  # Create the variable for proper countrynames using countryname-package
  library(countrycode)
  dat$countryname <- countrycode(dat$cntry, "iso2c", "country.name")
  
  # convert time column from Date to numeric
  dat$time <- eurotime2num(dat$time)
  
  #Detalle de los Datos
  
  dat <- dat[dat$geo %in% c("ES", "EU27", country),]
  dat <- dat[grepl(unidad, dat$unit),]
  dat <- dat[grepl(sexo, dat$sex),]
  dat <- dat[grepl(edad, dat$age),]
  if (!is.null(estacion)){
    dat <- dat[grepl(estacion, dat$s_adj),]
  }
  if (!is.null(worktime)){
    dat <- dat[grepl(worktime, dat$worktime),]
  }
  if (!is.null(educacion)){
    dat <- dat[grepl(educacion, dat$isced11),]
  }
  if (!is.null(indicador)){
    dat <- subset(dat,indic_em==indicador) 
  }
  dat2 <- dat[order(dat$geo,dat$time),] #ordena los datos por pa?ses y a?o
  
  #saveRDS(dat2, file="dat2.rds")
  
  return(dat2)
}

shinyServer(
  function(input, output) {
    
#     reactive({if (input$indicador == "NADA"){
#       input$indicador=NULL
#     }
#     if (input$estacion == "NADA"){
#       input$estacion=NULL
#     }
#     if (input$worktime == "NADA"){
#       input$worktime=NULL
#     }
#     })
    
    resultados <- reactive({
            euro2(input$concepto,
            input$pais,
            input$sexo, 
            input$unidad,
            input$edad,
            indicador=input$indicador,
            estacion=input$estacion,
            worktime=input$worktime,
            educacion =input$educacion)
    })
    
    output$grafico <- renderPlot({
      datos <- resultados()
      plot <- ggplot(datos, aes(x=time,y=values, group=geo, colour=geo))
      plot <- plot + geom_point() + geom_line()
      plot <- plot + coord_cartesian(xlim=c(2005:2015))
      plot <- plot + labs(x="Anio", y="Concepto")
      plot
    })
    
    output$tabla <- renderTable({
      datos <- resultados()
      dat3 <- datos[,c("geo","time", "values")]
      #Los los paquetes para la var% son plyr y quantmod
      
      #Calculamos la Var %
      variaciones <- ddply(dat3, "geo", transform,  DeltaCol = Delt(values))
      #cambio <- colnames(variaciones)[length(colnames(variaciones))]
      #Cambiamos el nombre a las columnas
      library("plyr")
      variaciones <- plyr:: rename(variaciones,c("geo"="Pais","time"="Year","values"="valor",
                                                 "Delt.1.arithmetic"="Var. Porcentual"))
      #Multiplicamos la variaci?n por 100 (%)
      variaciones$`Var. Porcentual`= variaciones$`Var. Porcentual`*100
      
      #Hacemos una tabla por pa?s
      paises <- unique(variaciones$Pais)
      pais1 <- variaciones[variaciones$Pais==paises[1],]
      pais2 <- variaciones[variaciones$Pais==paises[2],]
      pais3 <- variaciones[variaciones$Pais==paises[3],]
      paises2 <- as.character(paises)
      
      #Montamos la tabla final
      TablaProv <- merge(pais1, pais2, by="Year", all=TRUE)
      Tabla <- merge(TablaProv, pais3, by="Year", all=TRUE)
      #Eliminamos columnas
      for(i in seq(2, 6, by = 2)){
        Tabla[,i] <- NULL
      }
      #Cambiamos los nombres de las columnas
      for(i in seq(2, 6, by = 2)){
        names(Tabla)[i] <- paises2[i/2]
      }
      #Cambiamos el Anio a caracter, para que desaparezcan los decimales
      Tabla[, c(1)] <- sapply(Tabla[, c(1)], as.character)
      colnames(Tabla)[1]='Anio'
      colnames(Tabla)[3]='Variacion Porcentual'
      colnames(Tabla)[5]='Variacion  Porcentual'
      colnames(Tabla)[ncol(Tabla)]='Variacion Porcentual '
      #Datos a partir del 2005
      Tablon <- subset(Tabla, Tabla$Anio >= 2005)
      },bordered = TRUE,
      striped = TRUE,
      align = 'c',
      spacing = 'm',
      width = '20cm')
    
    
    output$downloadReport <- downloadHandler(
      filename = function() {
        paste('reporte', sep = '.', switch(
          input$format, PDF = 'pdf'
        ))
      },
      
      
      content = function(file) {
        src <- normalizePath('Prueba_reporte.Rmd')
        
        # temporarily switch to the temp dir, in case you do not have write
        # permission to the current working directory
        owd <- setwd(tempdir())
        on.exit(setwd(owd))
        file.copy(src, 'Prueba_reporte.Rmd', overwrite = TRUE)
      
        datos <- resultados()
        dat3 <- datos[,c("geo","time", "values")]
        #Los los paquetes para la var% son plyr y quantmod
        
        #Calculamos la Var %
        variaciones <- ddply(dat3, "geo", transform,  DeltaCol = Delt(values))
        #cambio <- colnames(variaciones)[length(colnames(variaciones))]
        #Cambiamos el nombre a las columnas
        library("plyr")
        variaciones <- plyr:: rename(variaciones,c("geo"="Pais","time"="Year","values"="valor",
                                                   "Delt.1.arithmetic"="Var. Porcentual"))
        #Multiplicamos la variaci?n por 100 (%)
        variaciones$`Var. Porcentual`= variaciones$`Var. Porcentual`*100
        
        #Hacemos una tabla por pa?s
        paises <- unique(variaciones$Pais)
        pais1 <- variaciones[variaciones$Pais==paises[1],]
        pais2 <- variaciones[variaciones$Pais==paises[2],]
        pais3 <- variaciones[variaciones$Pais==paises[3],]
        paises2 <- as.character(paises)
        
        #Montamos la tabla final
        TablaProv <- merge(pais1, pais2, by="Year", all=TRUE)
        Tabla <- merge(TablaProv, pais3, by="Year", all=TRUE)
        #Eliminamos columnas
        for(i in seq(2, 6, by = 2)){
          Tabla[,i] <- NULL
        }
        #Cambiamos los nombres de las columnas
        for(i in seq(2, 6, by = 2)){
          names(Tabla)[i] <- paises2[i/2]
        }
        #Cambiamos el Anio a caracter, para que desaparezcan los decimales
        Tabla[, c(1)] <- sapply(Tabla[, c(1)], as.character)
        colnames(Tabla)[1]='Anio'
        colnames(Tabla)[3]='Variacion Porcentual'
        colnames(Tabla)[5]='Variacion  Porcentual'
        colnames(Tabla)[ncol(Tabla)]='Variacion Porcentual '
        #Datos a partir del 2005
        Tablon <- subset(Tabla, Tabla$Anio >= 2005)
        
        library(rmarkdown)
        out <- render('Prueba_reporte.Rmd', switch(
          input$format,
          PDF = pdf_document()
        ))
        file.rename(out, file)
        
      }
    )
    
  }
)