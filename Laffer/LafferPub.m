%%
% *Curva de Laffer: Una introducción con MATLAB* 
%
%  A cotinuación se deriva una curva de Laffer para un impuesto al trabajo. Partimos de un mercado de trabajo clásico muy básico. 
%  
% 
%% Entorno
% Del lado de la demanda empleamos una función Cobb-Douglas estándar
% 
%
% $$Y=AK^{\frac{1}{3}}N^{\frac{2}{3}}$$
%
% obteniendo una demanda de trabajo convencional
%
% $$DN=\bigg(\frac{2}{3}\frac{A}{w}\bigg)^3K$$
%
% Del lado de la oferta usamos una función de utilidad simple
%
% $$U=\frac{c^\gamma}{\gamma}-N$$
% 
% sujeta a la restricción de presupuesto
% 
% $$C=(1-\tau_l)wN$$
% 
% a partir de la cual se obtiene la siguiente función de oferta de trabajo
% 
% $$ON=[(1-\tau_l)w]^{(\frac{\gamma}{1-\gamma})}$$
% 
% Un incremento en el impuesto al trabajo $\tau_l$ reduce la oferta de trabajo y por ende, la producción de la economía.
% 
% Para determinar el salario y empelo de equilibrio igualamos oferta y demanda
% 
% $$\bigg(\frac{2}{3}\frac{A}{w}\bigg)^3K=[(1-\tau_l)w]^{\frac{\gamma}{1-\gamma}}$$
% 
% Asumiendo que $\gamma=0,5$ el salario de equilibrio viene dado por
% 
% $$w=\bigg[ \bigg(\frac{2}{3}A\bigg)^3\frac{K}{1-\tau_l} \bigg]^{\frac{1}{4}}$$
% 
% Al aumentar el impuesto al trabajo $\tau_l$ cae la oferta de trabajo y sube el salario de equilibrio a la vez que disminuye el nivel de empleo.
% 
% La recaudación viene dada por el tipo impositivo $\tau_l$ multiplicado por el total de rentas salariales $W\times N$
% 
% $$\tau_l \times W \times N$$

%% Construyendo una Curva de Laffer
%
% Asignamos valores a $A=1$ y $K=400$ y calculamos la recaudación para
% cada tipo $\tau$

%%

  alfa  = 1/3;  
  K = 400;      
  A = 1;        
  gammal = 0.5; 

%% Funciones
%
% Primero definimos una serie de funciones necesarias para el cálculo
%
% Función de producción
%%
Y = @(alfa,A,K,N) ( A*(K^alfa)*(N^(1-alfa)) ); 
%%
% Demanda de Trabajo
%% 
DT = @(alfa,A,w,K) ( (((1-alfa)*(A/w))^3)*K );  
%%
% Oferta de Trabajo
%% 
OT = @(tl,w,gammal) ( ((1-tl)*w)^(gammal/(1-gammal)) );  
%%
% Función que define el exceso de demanda en el mercado de trabajo. Posteriormente pasamos esta función a un solver no lineal para encontrar el salario de equilibrio
%%
EDt = @(alfa,A,w,K,tl,gammal) (DT(alfa,A,w,K) - OT(tl,w,gammal)); 
%% Construcción del data frame con los datos
%
% Definimos un vector con los valores del impuesto y una matriz inicial a ser rellenada
%%
  t = 0.00:0.01:0.99;
  N = length(t);
  Tabla = zeros(N,5);
%%
% Hacemos un bucle que genera los datos de recaudación, empleo, salario y
% producción para cada tipo $\tau_l$
%%
for i = 1:N
    Tabla(i,1)= t(i);
    ff = @(w) EDt(alfa,A,w,K,t(i),gammal);
    ww = fzero(ff,[0.1,20]);
    Tabla(i,2) = ww;
    N = DT(alfa,A,ww,K);
    Tabla(i,3) =N;
    Tabla(i,4) = t(i)*ww*N;
    Tabla(i,5) = Y(alfa,A,K,N);     
end
%% Gráficos
%
%%
  subplot(2,2,1)
  plot(t,Tabla(:,4))
  grid on
  title('Recaudacion')
  subplot(2,2,2)
  plot(t,Tabla(:,3))
  grid on
  title('Empleo')
  subplot(2,2,3)
  plot(t,Tabla(:,5))
  grid on
  xlabel('Impuesto')
  title('Produccion')
  subplot(2,2,4)
  plot(t,Tabla(:,2))
  grid on
  xlabel('Impuesto')
  title('Salario')
  suptitle('Curva de Laffer - Impuesto al Trabajo')
