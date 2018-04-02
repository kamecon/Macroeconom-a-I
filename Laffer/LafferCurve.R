## OBTENCION DE UNA CURVA DE LAFFER EN EL CASO DE UN IMPUESTO AL TRABAJO  ##
#  --    Autor: Kamal A. Romero S. --Contacto: karomero@ucm.es--          ##

# SUPUESTOS:
#
# Función de utilidad U=c^gamma/gamma-N sujeta a una restricción
# de presupuesto igual a C=(1-t_l)wN por lo que obtenemos una
# Oferta de Trabajo igual a [(1-t_l)w]^(gamma/1-gamma)
# 
# Función Cobb-Douglas estándar por lo que la Demanda de Trabajo
# viene dada por (alfa*A/w)^3K


## Paquetes empleados ----
PAQUETES <- c("pacman")
inst <- match(PAQUETES, .packages(all=TRUE))
need <- which(is.na(inst))
if (length(need) > 0) install.packages(PAQUETES[need])

pacman::p_load(ggplot2, reshape2)


## Curva de Laffer para un valor de gamma = 0.5 ----


#Función para encontrar el salario de equilibrio
f1 <- function(w, tl, alfa  = 2/3,  K = 400,   A = 1,   gamma.l = 0.5){
  # Calcula el exceso de demanda del mercado de trabajo
  # necesario para encontrar el salrio de equilibrio
  #
  # Args:
  #   w: salario
  #   tl: impuesto al trabajo
  #   alfa: participacion del capital en la funcion de produccion (default=2/3)
  #   K: stock de capital (default=400)
  #   A: productividad total de los factores TFP (default=1)
  #   gamma.l: elasticidad de sustitucion del consumo (default=0.5)
  #
  # Returns:
  #   ed: El exceso de demanda en el mercado de trabajo definido como
  #   la  diferencia entre demanda y oferta de trabajo
  
  # Consideramos solo funciones de produccion con rendimientos
  # constantes a escala
    if (alfa > 1 | alfa < 0) {
    stop(" 'alfa' debe ser un numero entre cero y uno", call. = FALSE)
  }
  
  #Exceso de demanda
  ed <- (demanda_trabajo(w, alfa, K, A)-oferta_trabajo(w, tl, gamma.l))
  
} 

demanda_trabajo <- function(w, alfa  = 2/3,  K = 400,   A = 1){
  # Calcula la demanda de trabajo
  #
  # Args:
  #   w: salario
  #   alfa: participacion del capital en la funcion de produccion (default=2/3)
  #   K: stock de capital (default=400)
  #   A: productividad total de los factores TFP (default=1)
  #
  # Returns:
  #   dl: Demanda de trabajo obtenida a partir de una funcion de
  #   produccion Cobb-Douglas
  
  # Consideramos solo funciones de produccion con rendimientos
  # constantes a escala
  if (alfa > 1 | alfa < 0) {
    stop(" 'alfa' debe ser un numero entre cero y uno", call. = FALSE)
  }
  
  dl <- ((alfa*(A/w))^3)*K
}

oferta_trabajo <- function(w, tl,  gamma.l = 0.5){
  # Calcula la oferta de trabajo
  #
  # Args:
  #   w: salario
  #   tl: impuesto al trabajo
  #   gamma.l: elasticidad de sustitucion del consumo (default=0.5)
  #
  # Returns:
  #   ol: Oferta de trabajo obtenidad a partir de una funcion de
  #   utilidad U=c^gamma/gamma-N sujeta a una restricción de
  #   presupuesto igual a C=(1-t_l)wN
  
  ol <- ((1-tl)*w)^(gamma.l/(1-gamma.l))
}

produccion <- function(N, alfa  = 2/3,  K = 400,   A = 1){
  # Calcula la prouduccion
  #
  # Args:
  #   N: empleo que vacia el mercado de trabajo
  #   alfa: participacion del capital en la funcion de produccion (default=2/3)
  #   K: stock de capital (default=400)
  #   A: productividad total de los factores TFP (default=1)
  #
  # Returns:
  #   y: nivel de produccion obtenida a partir de una funcion de
  #   produccion Cobb-Douglas
  
  # Consideramos solo funciones con rendimientos constantes a escala
  if (alfa > 1 | alfa < 0) {
    stop(" 'alfa' debe ser un numero entre cero y uno", call. = FALSE)
  }
  
  y <- A*K^alfa*N^(1-alfa)
}



#Matriz inicial a ser rellenada
tabla <- matrix(ncol = 5, nrow = length(seq(0,0.99,0.01)))

#Bucle que genera los datos de recaudación, empleo, salario y producción para cada tipo t
contador <- 1
for(i in seq(0,0.99,0.01)){
  tabla[contador,1] <- i
  w <- uniroot(f1,c(0.1,20),tl=i)$root
  tabla[contador,2] <- w
  N <- demanda_trabajo(w)
  tabla[contador,3] <- N
  R <- i*w*N
  tabla[contador,4] <- R
  Y <- produccion(N)
  tabla[contador,5] <- Y
  contador <- contador + 1	
}

#Convierto la matriz a data frame
tabla.1 <- data.frame(tabla)

#Nombro las columnas
colnames(tabla.1) <- c('Impuesto','Salario','Empleo','Recaudacion','Produccion')

#Gráficos Individuales
l1 <- ggplot(data = tabla.1, aes(x=Impuesto,y=Recaudacion)) +
  geom_line(col="red") +
  ggtitle("Curva de Laffer - Impuesto al Trabajo") +
  theme(plot.title = element_text(hjust = 0.5))  #Esto es para centrar el título 
l1
ggsave('laffer.jpg')

l2 <- ggplot(data = tabla.1, aes(x=Impuesto,y=Empleo)) +
  geom_line(col="blue") +
  ggtitle("Curva de Laffer - Impuesto al Trabajo") +
  theme(plot.title = element_text(hjust = 0.5))  #Esto es para centrar el título 
l2
ggsave('laffer_empleo.jpg')

l3 <- ggplot(data = tabla.1, aes(x=Impuesto,y=Salario)) +
  geom_line(col="green") +
  ggtitle("Curva de Laffer - Impuesto al Trabajo") +
  theme(plot.title = element_text(hjust = 0.5))  #Esto es para centrar el título 
l3
ggsave('laffer_salario.jpg')

l4 <- ggplot(data = tabla.1, aes(x=Impuesto,y=Produccion)) +
  geom_line() +
  ggtitle("Curva de Laffer - Impuesto al Trabajo") +
  theme(plot.title = element_text(hjust = 0.5))  #Esto es para centrar el título 
l4
ggsave('laffer_produccion.jpg')

#Coloco la tabla en formaro flat para poder hacer el facet
tabla.flat <- melt(tabla.1, id.vars = c('Impuesto'))

#Se crea un factor para que en el gráfico aparezca el facet en el orden que yo quiero, el
#cual viene dado por la jerarquía del factor
tabla.flat$facet <- factor(tabla.flat$variable, levels = c('Recaudacion','Empleo','Produccion','Salario'))

#Las 4 tablas en un solo gráfico
lf <- ggplot(data = tabla.flat, aes(x=Impuesto, y=value)) +
  geom_line() +
  facet_wrap(~facet, scales = "free_y") +
  ggtitle("Curva de Laffer - Impuesto al Trabajo") +
  theme(plot.title = element_text(hjust = 0.5))  #Esto es para centrar el título 
lf
ggsave('laffer_all.jpg')
