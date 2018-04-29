﻿# Macroeconomía I

En el presente repositorio encontaras las presentaciones, apuntes y códigos empleados en la asignatura **Macroeoconomía I** que he dictado en los últimos años

## Carpetas

### Laffer

En esta carpeta encontrarás (de momento):

* Un código  `LafferCurve.R` a en el cual se obtiene una curva de Laffer a partir de un "modelo de juguete" del mercado de trabajo. Al ejecutar el código se generan 5 gráficos que serán guardados en el directorio de trabajo
* Un R Markdown `LafferMarkdown.Rmd` y su correspondiente .html donde se explica con detalle la obtención de la curva de Laffer. Pueden ver una versión publicada del html [acá](http://rpubs.com/Kamecon/384546)
* Otro R Markdown `LafferMarkdown2.Rmd` en el cual se incluye un análisis de sensibilidad con respecto a $\gamma$. Se representa el mismo a través de un gráfico dinámico hecho en `Shiny`, lo cual no me permite publicarlo en Rpubs ¿opciones?
* Notebook python `laffer_curve_python.ipynb` que reproduce el código original de `LafferCurve.R` en Python con texto explicativo.
* Notebook R `laffer_curve_r.ipynb` que reproduce el código original de `LafferCurve.R` en R con texto explicativo.
* Una versión del código en matlab `Laffer.m`, un script para la versión *publish* `LafferPub.m`y su correspondiente html `LafferPub.html`
* Notebook python `Laffer_simbolico.ipynb` donde se pretende replicar el ejercicio empleando la librería `Sympy`.

### ShinyEuro

En esta carpeta podran encontrar los shinys que uso en la asignatura, los cuales acceden a eurostat y descargan datos económicos. De momento tenemos:

* Un shiny (ver [acá](https://kamecon.shinyapps.io/PubFin/)) que muestra un gráfico y una tabla con datos de finanzas públicas (gasto, ingreso y saldo fiscal), los cuales pueden ser descargados en un pdf.

* otro que realiza lo mismo con datos de empleo (en revisión, aún sin subir)