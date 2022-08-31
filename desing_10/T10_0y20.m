%% Autor e información de utilidad
% ********                          Autor:                         ******** 
% Antonio Cameo del Rey

% ********                       Descripción:                      ********
% Analisis del diseño 10 con 0º de desfase y 20 mm de Gap 

clear all;
close all;


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
yCond2=20;
yCond=[yCond1',yCond2'];

% Distancia en mm de los núcleos al origen y=0
yNucleo1=-4;
yNucleo2=24;
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

% Obtengo la simulación en el eje Z
data=readtable('T10_RZ_0y20.csv');
%Renombramos las variables que exportamos de Ansys
H_RZ0y20 = data.Mag_H_kA_per_m__Freq__1MHz_Phase__0deg_;
x_RZ0y20 = data.Distance_mm_;

% Obtengo la simulación en el eje X y Y
data=readtable('T10_XY_0y20.csv');
%Renombramos las variables que exportamos de Ansys
H_XY0y20 = data.Mag_H_kA_per_m__Freq__1MHz_Phase__0deg_;
x_XY0y20 = data.Distance_mm_-150;

% Falta la simulación en 3D
data=readtable('T10_3D_0y20.csv');
%Renombramos las variables que exportamos de Ansys
H_3D0y20 = data.Mag_H_kA_per_meter__Freq__1MHz_Phase__0deg_;
x_3D0y20 = data.Distance_mm_-150;


%% Representación gráfica
% Analizo H_matlab debido a que aparentemente es no convergente y se
% aproxima a las distintas simulaciones con diferentes iteraciones

figure;


% RZ
subplot(2,2,1);
title('Comparación RZ, XY, 3D y Matlab, con el número optimo de iteraciones en RZ: 15');
xlabel('x (mm)');
ylabel('H (A/mm)');
grid on;
hold on;
legend;
%
nIteraciones=15;
[x_N,H_matlab]=Hfield(nNucleos,dCond,xDeltaCond,xMaxCond,yCond,yNucleo,I,nPasos,nIteraciones);
plot(x_N,abs(H_matlab),'k','DisplayName','H_m_a_t_l_a_b');
%
plot(x_RZ0y20,H_RZ0y20,'r-.','DisplayName','H_R_Z');
plot(x_XY0y20,H_XY0y20,'b-.','DisplayName','H_X_Y');
plot(x_3D0y20,H_3D0y20,'c-.','DisplayName','H_3_D');


% XY
subplot(2,2,2);
title('Comparación RZ, XY, 3D y Matlab, con el número optimo de iteraciones en XZ: 3');
xlabel('x (mm)');
ylabel('H (A/mm)');
grid on;
hold on;
legend;
%
nIteraciones=3;
[x_N,H_matlab]=Hfield(nNucleos,dCond,xDeltaCond,xMaxCond,yCond,yNucleo,I,nPasos,nIteraciones);
plot(x_N,abs(H_matlab),'k','DisplayName','H_m_a_t_l_a_b');
%
plot(x_RZ0y20,H_RZ0y20,'r-.','DisplayName','H_R_Z');
plot(x_XY0y20,H_XY0y20,'b-.','DisplayName','H_X_Y');
plot(x_3D0y20,H_3D0y20,'c-.','DisplayName','H_3_D');


% 3D
subplot(2,2,3);
title('Comparación RZ, XY, 3D y Matlab, con el número optimo de iteraciones en 3D: 12');
xlabel('x (mm)');
ylabel('H (A/mm)');
grid on;
hold on;
legend;
%
nIteraciones=12;
[x_N,H_matlab]=Hfield(nNucleos,dCond,xDeltaCond,xMaxCond,yCond,yNucleo,I,nPasos,nIteraciones);
plot(x_N,abs(H_matlab),'k','DisplayName','H_m_a_t_l_a_b');
%
plot(x_RZ0y20,H_RZ0y20,'r-.','DisplayName','H_R_Z');
plot(x_XY0y20,H_XY0y20,'b-.','DisplayName','H_X_Y');
plot(x_3D0y20,H_3D0y20,'c-.','DisplayName','H_3_D');



% Infinitas
subplot(2,2,4);
title('Comparación RZ, XY, 3D y Matlab, con iteraciones infinitas');
xlabel('x (mm)');
ylabel('H (A/mm)');
grid on;
hold on;
legend;
%
nIteraciones=100;
[x_N,H_matlab]=Hfield(nNucleos,dCond,xDeltaCond,xMaxCond,yCond,yNucleo,I,nPasos,nIteraciones);
plot(x_N,abs(H_matlab),'k','DisplayName','H_m_a_t_l_a_b');
%
plot(x_RZ0y20,H_RZ0y20,'r-.','DisplayName','H_R_Z');
plot(x_XY0y20,H_XY0y20,'b-.','DisplayName','H_X_Y');
plot(x_3D0y20,H_3D0y20,'c-.','DisplayName','H_3_D');

sgtitle('Modelo 10, Desfase: 0º, Gap: 20mm');


% Varias iteraciones
figure;
title('Comparación RZ, XY, 3D y Matlab con múltiple iteraciones', 'Modelo 10, Desfase: 0º, Gap: 20mm');
xlabel('x (mm)');
ylabel('H (A/mm)');
grid on;
hold on;
legend;

for i=2:4:16
    [x_N,H_matlab]=Hfield(nNucleos,dCond,xDeltaCond,xMaxCond,yCond,yNucleo,I,nPasos,i);
    plot(x_N,abs(H_matlab),'k-.','DisplayName','Iteraciones 2, 6, 10 y 14');
end
for i=4:4:16
    [x_N,H_matlab]=Hfield(nNucleos,dCond,xDeltaCond,xMaxCond,yCond,yNucleo,I,nPasos,i);
    plot(x_N,abs(H_matlab),'k:','DisplayName','Iteraciones 4, 8, 12 y 16');
end
plot(x_RZ0y20,H_RZ0y20,'r','DisplayName','H_R_Z');
plot(x_XY0y20,H_XY0y20,'b','DisplayName','H_X_Y');
plot(x_3D0y20,H_3D0y20,'c-.','DisplayName','H_3_D');





