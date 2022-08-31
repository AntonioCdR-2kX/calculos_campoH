%% Autor e información de utilidad
% ********                          Autor:                         ******** 
% Antonio Cameo del Rey

% ********                       Descripción:                      ********
% Analisis del diseño 8 con 0º de desfase y 20 mm de Gap 

clear all;
close all;


%% Campo H teórico
% Asigno los valores específicos para obtener el Campo H teórico con la función Hfield

% Número de nucleos del modelo, puede valer 0, 1 o 2
nNucleos=0;

% Diametro del conductor en mm, supongo el mismo en cada lado 
dCond11=4;
dCond12=4;
dCond13=4;
dCond21=4;
dCond22=4;
dCond23=4;
dCond=[dCond11',dCond12',dCond13',dCond21',dCond22',dCond23'];

% Distancia en mm de separación entre conductores
ldeltaCond11=5;
ldeltaCond12=5;
ldeltaCond13=5;
ldeltaCond21=5;
ldeltaCond22=5;
ldeltaCond23=5;
xDeltaCond=[ldeltaCond11',ldeltaCond12',ldeltaCond13',ldeltaCond21',ldeltaCond22',ldeltaCond23'];

% Distancia en mm del centro conductor mas alejado al centro
lmaxCond11=120;
lmaxCond12=120-25*1;
lmaxCond13=120-25*2;
lmaxCond21=120+20;
lmaxCond22=120+20-35*1;
lmaxCond23=120+20-35*2;
xMaxCond=[lmaxCond11',lmaxCond12',lmaxCond13',lmaxCond21',lmaxCond22',lmaxCond23'];

% Distancia en mm de cada grupo de conductores al origen y=0
yCond11=0;
yCond12=0;
yCond13=0;
yCond21=20;
yCond22=20;
yCond23=20;
yCond=[yCond11',yCond12',yCond13',yCond21',yCond22',yCond23'];

% Distancia en mm de los núcleos al origen y=0
yNucleo=0;

% Intensidad de la corriente en A de cada conductor en amperios
% Los valores 0 de las corrientes sobrantes deben ir al final
% del mas cercano al más lejano al centro
I11=[100 100 100];
I12=[100 100 100];
I13=[100 100 100];
I21=[100 100 100]; 
I22=[100 100 100]; 
I23=[100 100 100]; 
I=[I11',I12',I13',I21',I22',I23'];

% Numero de pasos a tomar 
nPasos=1000;


%% Numero de iteraciones
% Numero de veces que se aplica el método del espejo con los dos núcleos,
% si el número de núcleos no es 2, no se emplea

nIteraciones=4;


%% Función principal
[x_N,H_matlab]=Hfield(nNucleos,dCond,xDeltaCond,xMaxCond,yCond,yNucleo,I,nPasos,nIteraciones);


%% Campos H simulados
% Extraigo los datos simulados con Ansys en cada modelo, comento y descomentolos valores necesarios 

% Obtengo la simulación en el eje Z
data=readtable('T8_RZ_0y20.csv');
%Renombramos las variables que exportamos de Ansys
H_RZ0y20 = data.Mag_H_kA_per_m__Freq__1MHz_Phase__0deg_;
x_RZ0y20 = data.Distance_mm_;

% Obtengo la simulación en el eje X y Y
data=readtable('T8_XY_0y20.csv');
%Renombramos las variables que exportamos de Ansys
H_XY0y20 = data.Mag_H_kA_per_m__Freq__1MHz_Phase__0deg_;
x_XY0y20 = data.Distance_mm_-180;

% Simulación en 3D
data=readtable('T8_3D_0y20.csv');
% Renombramos las variables que exportamos de Ansys
H_3D0y20 = data.Mag_H_kA_per_meter__Freq__1MHz_Phase__0deg_;
x_3D0y20 = data.Distance_mm_-180;


%% Representación gráfica

figure;
%
title('Comparación RZ, XY, 3D y Matlab', 'Modelo 8, Desfase: 0º, Gap: 20mm');
xlabel('x (mm)');
ylabel('H (A/mm)');
grid on;
hold on;
legend;

% Represento el campo H teórico en negro
plot(x_N,abs(H_matlab),'k','DisplayName','H_m_a_t_l_a_b');
% Represento el campo simulado en RZ en rojo
plot(x_RZ0y20,H_RZ0y20,'r-.','DisplayName','H_R_Z');
% Represento el campo simulado en XY en azul
plot(x_XY0y20,H_XY0y20,'b-.','DisplayName','H_X_Y');
% Represento el campo simulado en 3D en cián
plot(x_3D0y20,H_3D0y20,'c-.','DisplayName','H_3_D');

% No tiene sentido emplear varías iteraciones, por tener un solo núcleo y
% estar limitado a 1 iteración como máximo
