%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% OBTENCION DE UNA CURVA DE LAFFER EN EL CASO DE UN IMPUESTO AL TRABAJO 
%                   Autor: Kamal A. Romero S.         
%                   Contacto: karomero@ucm.es 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% SUPUESTOS:
%
% Función de utilidad U=c^gamma/gamma-N sujeta a una restricción
% de presupuesto igual a C=(1-t_l)wN por lo que obtenemos una
% Oferta de Trabajo igual a [(1-t_l)w]^(gamma/1-gamma)
% 
% Función Cobb-Douglas estándar por lo que la Demanda de Trabajo
% viene dada por (alfa*A/w)^3K

%Parametros
alfa  = 2/3;  %participación del trabajo en la función de producción
K = 400;      %Stock de capital
A = 1;        %Productividad total de los factores TFP
gammal = 0.5; %Elasticidad de sustitución


%Definimos las funciones a utilizar
%Función de producción
Y = @(alfa,A,K,N) ( A*(K^alfa)*(N^(1-alfa)) ); 
%Demanda de Trabajo
DT = @(alfa,A,w,K) ( ((alfa*(A/w))^3)*K );  
%Oferta de Trabajo
OT = @(tl,w,gammal) ( ((1-tl)*w)^(gammal/(1-gammal)) );  
%Exceso de demanda
EDt = @(alfa,A,w,K,tl,gammal) (DT(alfa,A,w,K) - OT(tl,w,gammal)); 
%Definimos el exceso de demanda como función solo del salario
%ED = @(w) EDt(alfa,A,w,K,tl,gammal); 

%Vector de impuestos
t = 0.00:0.01:0.99;
N = length(t);

%Inicializamos la tabla a rellenar
Tabla = zeros(N,5);

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

%Grafico
subplot(2,2,1)
plot(t,Tabla(:,4))
grid on
   xlabel('Impuesto')
   ylabel('Recaudacion')
subplot(2,2,2)
plot(t,Tabla(:,3))
grid on
   xlabel('Impuesto')
   ylabel('Empleo')
subplot(2,2,3)
plot(t,Tabla(:,5))
grid on
   xlabel('Impuesto')
   ylabel('Produccion')
subplot(2,2,4)
plot(t,Tabla(:,2))
grid on
   xlabel('Impuesto')
   ylabel('Salario')
suptitle('Curva de Laffer - Impuesto al Trabajo')