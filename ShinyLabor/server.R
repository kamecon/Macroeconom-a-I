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

clean_eurostat_cache()

dat <- get_eurostat("une_rt_a", time_format = "raw")

euro2 <- function(dat,
                  country,
                  sexo,
                  unidad,
                  edad){
  
  #Limpiar cach?
  #clean_eurostat_cache()
  
  #Dato a buscar
  #  dat <- get_eurostat(concepto, time_format = "raw")
  
  # Extract the information on country in question. (First two character in region string mark the country)
  dat$cntry <- substr(dat$geo, 1,2)
  
  # Create the variable for proper countrynames using countryname-package
  #library(countrycode)
  #dat$countryname <- countrycode(dat$cntry, "iso2c", "country.name")
  
  # convert time column from Date to numeric
  dat$time <- eurotime2num(dat$time)
  
  #Detalle de los Datos (esto para pestania de paro)
  
  dat %>% dplyr::filter(geo %in% c("ES", "EU27", country),
                        unit == unidad & sex == sexo & age == edad) %>%
    dplyr::arrange(geo, time) -> dat2
  
  # dat <- dat[dat$geo %in% c("ES", "EU27", country),]
  # dat <- dat[grepl(unidad, dat$un it),]
  # dat <- dat[grepl(sexo, dat$sex),]
  # dat <- dat[grepl(edad, dat$age),]
  # if (!is.null(estacion)){
  #   dat <- dat[grepl(estacion, dat$s_adj),]
  # }
  # if (!is.null(worktime)){
  #   dat <- dat[grepl(worktime, dat$worktime),]
  # }
  # if (!is.null(educacion)){
  #   dat <- dat[grepl(educacion, dat$isced11),]
  # }
  # if (!is.null(indicador)){
  #   dat <- subset(dat,indic_em==indicador) 
  # }
  # dat2 <- dat[order(dat$geo,dat$time),] #ordena los datos por pa?ses y a?o
  # 
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
      # euro2(input$concepto,
      #       input$pais,
      #       input$sexo, 
      #       input$unidad,
      #       input$edad,
      #       indicador=input$indicador,
      #       estacion=input$estacion,
      #       worktime=input$worktime,
      #       educacion =input$educacion)
      euro2(dat,
        input$pais,
        input$sexo, 
        input$unidad,
        input$edad)
    })
    
    output$grafico <- renderPlot({
      
      datos <- resultados()
      plot <- ggplot(datos, aes(x=time,y=values, group=geo, colour=geo)) +
        geom_point() + geom_line() +
        coord_cartesian(xlim=c(2005:2017)) +
        labs(x="Anio", y=toString(input$variable)) +
        scale_x_continuous(breaks = c(2005,2007,2009,2011,2013,2015,2017))
      plot
      
      
      # datos <- resultados()
      # plot <- ggplot(datos, aes(x=time,y=values, group=geo, colour=geo))
      # plot <- plot + geom_point() + geom_line()
      # plot <- plot + coord_cartesian(xlim=c(2005:2015))
      # plot <- plot + labs(x="Anio", y="Concepto")
      # plot
    })
    
    output$tabla <- renderTable({
      datos <- resultados()
      
      
      # Seleccionamos las columnas que nos interesan (pa?s, anio y valores de la variable), agrupamos por pa?s y calculamos las variaciones porcentuales. Finalmente nos quedamos solo con los anios 2005 en adelante 
      datos %>% dplyr::select(geo, time, values) %>%
        dplyr::group_by(geo) %>%
        dplyr::mutate(var_porct = (values/lag(values) -1)*100) %>%
        dplyr::filter(time >=2005) -> datos2P
      
      #creamos un vector con los pa?ses
      paises <- unique(datos2P$geo)
      
      #Tenemos una tabla 'flat' pero nos interesa obtener una tabla en la cual cada pa?s est? 'al lado del otro' para un anio dado. Para eso creamos una lista donde cada elemento son los datos correspondientes a cada pa?s (una especie de sub-tabla). Luego hacemos un join de las tres sub-tablas y ya tenemos el aspecto que deseamos
      
      provisional <- list() #Lista vac?a
      
      #creamos las sub-tablas para cada pa?s
      for (i in seq_along(paises)) {  
        provisional[[i]] <- datos2P %>%
          dplyr::filter(geo==paises[i])
      }
      
      #Hacemos el join de las 3 sub-tablas y cambiamos el orden de las columnas para colocar el anio en la primera columna
      Tabla <- provisional %>%
        purrr::reduce(dplyr::full_join, by = "time") %>%
        dplyr::select(time, geo.x, values.x:var_porct) -> Tabla  
      
      
      # dat3 <- datos[,c("geo","time", "values")]
      # #Los los paquetes para la var% son plyr y quantmod
      # 
      # #Calculamos la Var %
      # variaciones <- ddply(dat3, "geo", transform,  DeltaCol = Delt(values))
      # #cambio <- colnames(variaciones)[length(colnames(variaciones))]
      # #Cambiamos el nombre a las columnas
      # library("plyr")
      # variaciones <- plyr:: rename(variaciones,c("geo"="Pais","time"="Year","values"="valor",
      #                                            "Delt.1.arithmetic"="Var. Porcentual"))
      # #Multiplicamos la variaci?n por 100 (%)
      # variaciones$`Var. Porcentual`= variaciones$`Var. Porcentual`*100
      # 
      #Hacemos una tabla por pa?s
      # paises <- unique(variaciones$Pais)
      # pais1 <- variaciones[variaciones$Pais==paises[1],]
      # pais2 <- variaciones[variaciones$Pais==paises[2],]
      # pais3 <- variaciones[variaciones$Pais==paises[3],]
      # paises2 <- as.character(paises)
      # 
      # #Montamos la tabla final
      # TablaProv <- merge(pais1, pais2, by="Year", all=TRUE)
      # Tabla <- merge(TablaProv, pais3, by="Year", all=TRUE)
      
      #Cambiamos el nombre de las columnas con los datos por el del pa?s correspondiente
      for(i in seq(3, 9, by = 3)){  
        colnames(Tabla)[i] <- as.character(paises[(i/3)])
      }
      
      
      #Eliminamos las columnas que traen el nombre del pa?s para cada observaci?n dado que no nos hacen falta. Antes de eso hay que hacer un ungroup, en caso contrario mantendr?a una de las columnas que deseamos eliminar, dado que dplyr mantiene la columna de agrupaci?n
      Tabla %>%
        dplyr::ungroup() %>%
        dplyr::select(-dplyr::starts_with('geo')) -> Tabla
      
      
      #Colocamos el nombre a la columna de variacion porcentual y anio
      for(i in seq(3, 7, by = 2)){
        colnames(Tabla)[i] <- "Variacion Porcentual"
      }
      
      colnames(Tabla)[1] <- "Anio"
      
      #Cambiamos el anio a caracter, para que desaparezcan los decimales
      Tabla[, c(1)] <- sapply(Tabla[, c(1)], as.character)
      
      Tablon <- Tabla
      
      
      # #Eliminamos columnas
      # for(i in seq(2, 6, by = 2)){
      #   Tabla[,i] <- NULL
      # }
      # #Cambiamos los nombres de las columnas
      # for(i in seq(2, 6, by = 2)){
      #   names(Tabla)[i] <- paises2[i/2]
      # }
      # #Cambiamos el Anio a caracter, para que desaparezcan los decimales
      # Tabla[, c(1)] <- sapply(Tabla[, c(1)], as.character)
      # colnames(Tabla)[1]='Anio'
      # colnames(Tabla)[3]='Variacion Porcentual'
      # colnames(Tabla)[5]='Variacion  Porcentual'
      # colnames(Tabla)[ncol(Tabla)]='Variacion Porcentual '
      # #Datos a partir del 2005
      # Tablon <- subset(Tabla, Tabla$Anio >= 2005)
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
        
        #datos <- resultados()
        datos <- resultados()
        
        datos %>% dplyr::select(geo, time, values) %>%
          dplyr::group_by(geo) %>%
          dplyr::mutate(var_porct = (values/lag(values) -1)*100) %>%
          dplyr::filter(time >=2005) -> datos2P
        
        paises <- unique(datos2P$geo)
        
        
        provisional <- list() 
        
        for (i in seq_along(paises)) {
          provisional[[i]] <- datos2P %>%
            dplyr::filter(geo==paises[i])
        }
        
        Tabla <- provisional %>%
          purrr::reduce(dplyr::full_join, by = "time") %>%
          dplyr::select(time, geo.x, values.x:var_porct) -> Tabla  
        
        for(i in seq(3, 9, by = 3)){
          colnames(Tabla)[i] <- as.character(paises[(i/3)])
        }
        
        
        Tabla %>%
          dplyr::ungroup() %>%
          dplyr::select(-dplyr::starts_with('geo')) -> Tabla
        
        
        for(i in seq(3, 7, by = 2)){
          colnames(Tabla)[i] <- "Variacion Porcentual"
        }
        
        colnames(Tabla)[1] <- "Anio"
        
        
        
        Tablon <- Tabla 
        
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