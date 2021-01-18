# Aplicación web que permite visualizar datos de la base de datos de finanzas públicas de 
# Eurostat (gov_10a_main) a través de un gráfico y una tabla, asi como descargar los mismos
# en un documento .pdf
#                   Elaborado por Kamal Romero (karomero@ucm.es)


#Limpiar cache
clean_eurostat_cache()

#Dato a buscar
#dat <- get_eurostat("gov_10a_main", time_format = "raw")

 datosBase <- function(fuente){
   datos <- get_eurostat(fuente, time_format = "raw")
   return(datos)
 }



euro_gov <- function(dat,
                     variable,
                     country){
  

  
  # convert time column from Date to numeric
  dat$time <- eurotime2num(dat$time)
  
  
  #Seleccionamos los datos que nos interesan y los ordenamos por país y año
  
  dat %>% dplyr::filter(geo %in% c("ES", "EU28", country),
                        unit == "PC_GDP" & sector == 'S13'& na_item == variable) %>%
    dplyr::arrange(geo, time) -> dat2
  

  return(dat2)
}

shinyServer(
  function(input, output) {
    
     dat <- reactive({
       datosBase(input$fuente)
     })
    
    resultados <- reactive({
      euro_gov(dat(),
               input$variable,
               input$pais)
    })
    
    #Gráfico
    
    output$grafico <- renderPlot({
      datos <- resultados()
      plot <- ggplot(datos, aes(x=time,y=values, group=geo, colour=geo)) +
              geom_point() + geom_line() +
              labs(x="Año", y=toString(input$variable)) +
              scale_x_continuous(limits = c(2005,2019), breaks = seq(2005,2019,2))
      plot
    })
    
    output$tabla <- renderTable({
      datos <- resultados()
      
      # Seleccionamos las columnas que nos interesan (país, año y valores de la variable), agrupamos por país y calculamos las variaciones porcentuales. Finalmente nos quedamos solo con los años 2005 en adelante 
      datos %>% dplyr::select(geo, time, values) %>%
        dplyr::group_by(geo) %>%
        dplyr::mutate(var_porct = (values/lag(values) -1)*100) %>%
        dplyr::filter(time >=2005) -> datos2P
      
      #creamos un vector con los países
      paises <- unique(datos2P$geo)

      
      #Tenemos una tabla 'flat' pero nos interesa obtener una tabla en la cual cada país está 'al lado del otro' para un año dado. Para eso creamos una lista donde cada elemento son los datos correspondientes a cada país (una especie de sub-tabla). Luego hacemos un join de las tres sub-tablas y ya tenemos el aspecto que deseamos
      
      provisional <- list() #Lista vacía
      
      #creamos las sub-tablas para cada país
      for (i in seq_along(paises)) {  
        provisional[[i]] <- datos2P %>%
          dplyr::filter(geo==paises[i])
      }
      
      #Hacemos el join de las 3 sub-tablas y cambiamos el orden de las columnas para colocar el año en la primera columna
      Tabla <- provisional %>%
        purrr::reduce(dplyr::full_join, by = "time") %>%
        dplyr::select(time, geo.x, values.x:var_porct) -> Tabla  
      
      #Cambiamos el nombre de las columnas con los datos por el del país correspondiente
      for(i in seq(3, 9, by = 3)){  
        colnames(Tabla)[i] <- as.character(paises[(i/3)])
      }
      
      
      #Eliminamos las columnas que traen el nombre del país para cada observación dado que no nos hacen falta. Antes de eso hay que hacer un ungroup, en caso contrario mantendría una de las columnas que deseamos eliminar, dado que dplyr mantiene la columna de agrupación
      Tabla %>%
        dplyr::ungroup() %>%
        dplyr::select(-dplyr::starts_with('geo')) -> Tabla
      
      
      #Colocamos el nombre a la columna de variacion porcentual y año
      for(i in seq(3, 7, by = 2)){
        colnames(Tabla)[i] <- "Variacion Porcentual"
      }
      
      colnames(Tabla)[1] <- "Año"
      
      #Cambiamos el año a caracter, para que desaparezcan los decimales
      Tabla[, c(1)] <- sapply(Tabla[, c(1)], as.character)

      Tablon <- Tabla
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
      
      
      
      #Reporte en pdf
      
      content = function(file) {
        src <- normalizePath('Prueba_reporte.Rmd')
        
        # temporarily switch to the temp dir, in case you do not have write
        # permission to the current working directory
        owd <- setwd(tempdir())
        on.exit(setwd(owd))
        file.copy(src, 'Prueba_reporte.Rmd', overwrite = TRUE)
        
        #Repetimos los pasos anteriores para realizar la tabla
        
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
        
        colnames(Tabla)[1] <- "Año"
        
        

        Tablon <- Tabla 
     
        
        
        #library(rmarkdown)
        out <- render('Prueba_reporte.Rmd', switch(
          input$format,
          PDF = pdf_document()
        ))
        file.rename(out, file)
      }
    )
    
  }
)