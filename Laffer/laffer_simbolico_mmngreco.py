
# coding: utf-8

# # Máximo de la curva de Laffer
# 
# A continuación se presenta un ejercicio analítico cuyo objetivo es obtener los determinantes del máximo de una curva de Laffer muy sencilla mediante el uso de la librería de lenguaje simbólico de Python *Sympy*.
# 
# Partimos de la curva de Laffer obtenida en el resto de los ejercicios del respositorio
# 
# ## Importamos las librerías necesarias
# 

# In[1]:

import sympy as sp
import matplotlib.pyplot as plt


# In[2]:

get_ipython().run_line_magic('matplotlib', 'inline')
sp.init_printing()


# ## Definimos los símbolos

# In[3]:

K, A, N, a, r, rmg, w, t, g, c, N, y, ymg, u, umg = sp.symbols(
    r"K A N \alpha R R' w \tau_l \gamma c N y y' u u'", 
    real=True
)


# Empezamos por el problema del consumidor, definido por la función de utilidad y la restricción de presupuesto
# 
# ## Función de utilidad
# 

# In[4]:

U = (c**g)/g - N
U


# In[5]:

sp.Eq(u, U)


# ## Restricción presupuestaria

# In[6]:

C = (1-t)*w*N
C


# In[7]:

sp.Eq(c, C)


# Sustituimos la restricción de presupuesto en la función de utilidad

# In[8]:

U = U.subs(c, C)
U


# In[9]:

sp.Eq(u, U)


# # Calculamos la utilidad marginal

# In[10]:

Umg = U.diff(N)#.subs(g, 0.5)
Umg


# In[11]:

sp.Eq(umg, Umg)


# Obtenemos el nivel de empleo que maximiza la utilidad $Umg = 0$
# > **NOTA: workaround**

# In[12]:

t_eq = sp.Eq(sp.solve(Umg, t)[0], t)  # workaround
ON = sp.solve(t_eq, N)[0]
ON


# In[13]:

sp.Eq(N,ON)


# Ahora pasemos al lado de la producción
# 
# ## Función de Producción

# In[14]:

Y = A*K**(a)*N**(1-a)
Y


# In[15]:

sp.Eq(y, Y)


# # Calculamos el producto marginal

# In[16]:

Pmg = Y.diff(N)
Pmg


# Obtenemos la demanda de trabajo como aquel que iguala el producto marginal al salario real

# In[17]:

DN = sp.solve(Pmg-w, N)[0]
DN
sp.Eq(N, DN)


# ## Nivel de empleo de equilibrio
# 
# Resolvemos para el nivel de salario de equilibrio

# In[18]:

w_eq = sp.solve(DN-ON, w)[0]
sp.Eq(w, w_eq)


# ## Recaudación
# 
# La recaudación viene dada por el tipo impositivo $\tau_l$ multiplicado por el total de rentas salariales $W\times N$

# In[19]:

R = w_eq*t*ON
sp.Eq(r,R)


# Empleando la oferta de trabajo en la expresión anterior, observamos que la recaudación depende (en parte, si sustituimos $w$ por su versión de equilibrio tambien entrarían los parámetros de la función de producción) del salario, el tipo impositivo y de la importancia relativa del consumo en la función de utilidad.
# 
# Si maximizamos la recaudación con respecto al tipo impositivo ¿qué obtendríamos?. Primero derivamos

# In[20]:

Rmg = R.diff(t)
sp.Eq(rmg, Rmg.simplify())


# Resolvemos esta ecuación para $\tau_l$

# In[21]:

t_eq = sp.solve(Rmg,t)[0].factor()
sp.Eq(t,t_eq)


# El máximo de la curva de Laffer solo depende de la importancia relativa del consumo en la función de utilidad, parámetro determinante de la elasticidad de la oferta de trabajo, el máximo debería depender también de los parámetros de la función de producción ~~pero como no hemos empleado el salario de equilibrio en la recaudación no se observa~~.
