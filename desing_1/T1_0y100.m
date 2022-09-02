%% Autor e información de utilidad
% ********                          Autor:                         ******** 
% Antonio Cameo del Rey

% ********                       Descripción:                      ********
% Analisis del diseño 1 con 0º de desfase y 100 mm de Gap 

clear all;
% close all;


%% Campo H teórico
% Asigno los valores específicos para obtener el Campo H teórico con la función Hfield

% Número de nucleos del modelo, puede valer 0, 1 o 2
nNucleos=2;

% Diametro del conductor en mm, supongo el mismo en cada lado 
dCond1=4;
dCond2=4;
dCond=[dCond1',dCond2'];

% Distancia en mm de separación entre conductores
ldeltaCond1=5;
ldeltaCond2=5;
xDeltaCond=[ldeltaCond1',ldeltaCond2'];

% Distancia en mm del centro conductor mas alejado al centro
lmaxCond1=100;
lmaxCond2=100;
xMaxCond=[lmaxCond1',lmaxCond2'];

% Distancia en mm de cada grupo de conductores al origen y=0
yCond1=0;
yCond2=100;
yCond=[yCond1',yCond2'];

% Distancia en mm de los núcleos al origen y=0
yNucleo1=-4;
yNucleo2=104;
yNucleo=[yNucleo1',yNucleo2'];

% Intensidad de la corriente en A de cada conductor en amperios
% Los valores 0 de las corrientes sobrantes deben ir al final
% del mas cercano al más lejano al centro
I1=[100 100 100 100 100 100];
I2=[100 100 100 100 100 100];
I=[I1',I2'];

% Numero de pasos a tomar 
nPasos=1000;


%% Numero de iteraciones
% Numero de veces que se aplica el método del espejo con los dos núcleos,
% si el número de núcleos no es 2, no se emplea

% *** Introduzco el número de iteraciones posteriormente ***


%% Función principal
%[x_N,H_matlab]=Hfield(nNucleos,dCond,xDeltaCond,xMaxCond,yCond,yNucleo,I,nPasos,nIteraciones);

% *** Ejecuto la función principal posteriormente ***


%% Campo H simulado
% Extraigo los datos simulados con Ansys en cada modelo, comento y descomentolos valores necesarios 

% Simulación en 3D
data=readtable('T10_3D_0y100.csv');
%Renombramos las variables que exportamos de Ansys
H_3D0y100 = data.Mag_H_kA_per_meter__Freq__1MHz_Phase__0deg_;
x_3D0y100 = data.Distance_mm_-150;


%% Calculos para la gráfica ampliada y el error relativo
% Definimos las x de comienzo y fin de la zona de ampliación en los
% conductores

xCond=xMaxCond;
j=0;
while j==0 
    [xMax,nMax]=max(xCond);
    if yCond(nMax)==yCond(1)
        j=1;
    else
        xCond(nMax)=0;
    end    
end

xCond=xMaxCond;
j=0;
while j==0 
    [xMin,nMin]=min(xCond);
    if yCond(nMin)==yCond(1)
        j=1;
    else 
        xCond(nMin)=1000;
    end    
end   
    
xMax=xMax+dCond(nMax);
xMin=xMin-dCond(nMin)-xDeltaCond(nMin)*(size(I(:,nMin),1)-1);


%% Representación gráfica
% Analizo H_matlab debido a que aparentemente es no convergente y se
% aproxima a las distintas simulaciones con diferentes iteraciones

% Varias iteraciones con 3D
figure;
title('Comparación de la simulación en 3D y Matlab, con múltiples iteraciones', 'Modelo 1, Desfase: 0º, Gap: 100mm');
xlabel('x (mm)');
ylabel('H (A/mm)');
grid on;
hold on;
legend;

% Con 5 iteraciones
nIteraciones=5;
[x_N,H_matlab]=Hfield(nNucleos,dCond,xDeltaCond,xMaxCond,yCond,yNucleo,I,nPasos,nIteraciones);
plot(x_N,abs(H_matlab),'r-.','DisplayName','H_m_a_t_l_a_b con 5 iteraciones');
[x5_Zoom,H5_Zoom,~]=Zoom(x_N,H_matlab,xMin,xMax,nPasos);

% Con 10 iteraciones
nIteraciones=10;
[x_N,H_matlab]=Hfield(nNucleos,dCond,xDeltaCond,xMaxCond,yCond,yNucleo,I,nPasos,nIteraciones);
plot(x_N,abs(H_matlab),'b-.','DisplayName','H_m_a_t_l_a_b con 10 iteraciones');
[x10_Zoom,H10_Zoom,~]=Zoom(x_N,H_matlab,xMin,xMax,nPasos);

% Con 100 iteraciones
nIteraciones=100;
[x_N,H_matlab]=Hfield(nNucleos,dCond,xDeltaCond,xMaxCond,yCond,yNucleo,I,nPasos,nIteraciones);
plot(x_N,abs(H_matlab),'c-.','DisplayName','H_m_a_t_l_a_b con 100 iteraciones');
[x100_Zoom,H100_Zoom,~]=Zoom(x_N,H_matlab,xMin,xMax,nPasos);

plot(x_3D0y100,H_3D0y100,'k','DisplayName','H_3_D');
[x3D_Zoom,H3D_Zoom,n_Zoom]=Zoom(x_3D0y100,H_3D0y100,xMin,xMax,nPasos);


%% Representación en gráfica ampliada y el error relativo

figure;
title('Ampliación en el entorno de los conductores', 'Modelo 1, Desfase: 0º, Gap: 100mm');
xlabel('x (mm)');
ylabel('H (A/mm)');
grid on;
hold on;
legend;

plot(x5_Zoom,abs(H5_Zoom),'r-.','DisplayName','H_m_a_t_l_a_b con 5 iteraciones');
E5_relativo=calculo_E(H3D_Zoom,abs(H5_Zoom),n_Zoom)

plot(x10_Zoom,abs(H10_Zoom),'b-.','DisplayName','H_m_a_t_l_a_b con 10 iteraciones');
E10_relativo=calculo_E(H3D_Zoom,abs(H10_Zoom),n_Zoom)

plot(x100_Zoom,abs(H100_Zoom),'c-.','DisplayName','H_m_a_t_l_a_b con 100 iteraciones');
E100_relativo=calculo_E(H3D_Zoom,abs(H100_Zoom),n_Zoom)

plot(x3D_Zoom,H3D_Zoom,'k','DisplayName','H_3_D');




%% Zoom en varias iteracionescon 3D
function [xZoom,HZoom,nZoom] =Zoom(x,H,xMin,xMax,nPasos)

for i=1:nPasos
    if x(i)<xMin
        nMin=i;
    end
    if x(i)<xMax
        nMax=i;
    end
end
nZoom=nMax-nMin;
xZoom=x(nMin:nMax);
HZoom=H(nMin:nMax);

end


%% Error relativo
function E_relativo=calculo_E(H_sim,H_teo,nPasos)

suma_E_relativo=0;
for i=1:nPasos
    suma_E_relativo=suma_E_relativo+abs(H_sim(i)-abs(H_teo(i)))./abs(H_sim(i));
end
E_relativo=suma_E_relativo/nPasos*100;

end

