%% Autor e información de utilidad
% ********                          Autor:                         ******** 
% Antonio Cameo del Rey

% ********                       Descripción:                      ********
% Esta función envía en la variable H_total el campo H en la 
% ordenada del primer conductor envíado y la abcisa correspondiente en la 
% variable x_N. 

% ********                          Nota 1:                        ********
% Se podrán introducir innumerables conductores de diametros e intensidades 
% diferentes pero deberán introducirse mediante distintas
% columnas a las que se usen para los demás conductores

% ********                          Nota 2:                        ********
% Se podrá usar la misma columna para conductores uniformente distribuidos 
% en la misma ordenada y separados entre sí xDeltaCond 

% ********                          Nota 3:                        ********
% Es importante, aunque no imprescindible, que el primer conductor, el que 
% define la ordenasda a estudiar, sea también el más alejado de dicha 
% ordenada.


%% Variables de entrada
% nNucleos - Número de núcleos, podrá vale 0, 1 o 2.
% dCond - Diámetro de los conductores.
% xDeltaCond - Separación entre los conductores.
% xMaxCond - Distancia del conductor más externo al centro.
% yCond - Distancia de cada grupo de conductores al origen y=0.
% yNucleo - Distancia de los núcleos al origen y=0.
% I - Intensidad de cada conductor.
% nPasos - Número de puntos (pasos) que analizar en el eje x.
% nIteraciones - Número de veces que aplicar el método "mirroring" 

function [x_N,H_final] = Hfield(nNucleos,dCond,xDeltaCond,xMaxCond,yCond,yNucleo,I,nPasos,nIteraciones)


%% Avisos y verificaciones

% Verificación de que el número de iteraciones se corresponda con el número
% de núcleos
if nNucleos==1 && nIteraciones>1
    % mostrar un warning
    warning('Con un núcleo no se permiten realizar iteraciones superiores a 1, se ha cambiado nIteraciones a 1');
    nIteraciones=1;
elseif nNucleos==0 && nIteraciones~=0
    % mostrar otro warning
    warning('Sin núcleo no se permiten realizar iteraciones, se ha cambiado nIteraciones a 0');
    nIteraciones=0;
end


%% Variables deducidas

% Obtenemos el número de bobinas con las columnas de I para cada grupo de
% conductores
n_bobinas=size(I,2);

% Obtenemos el número de conductores que hay en cada agrupación de bobinas
nCond=zeros(n_bobinas,1);
for i=1:n_bobinas
    nCond(i)=2*size( find(I(:,i)~=0) , 1 );
end

%
if nNucleos==0
    nIteraciones=0;
    nNucleos=1;
end


%% Obtención de las posiciones x a estudiar: X_N

% Puntos x a estudiar
x_N=zeros(nPasos,1);

% Para establecer la x máxima que analizar tomamos un 1.5 veces la 
% distancia del centro del conductor de la ordenada estudiada 
xMax=3/2*xMaxCond(1);
for i=1:(nPasos)
    x_N(i)=-xMax+2*(xMax/nPasos)*(i-1);
end
% x_N


%% Obtención de la distribución de los conductores: xI_N

% Posición de los conductores
xI_N=zeros(max(nCond),n_bobinas);

% nB, nos permite tener constancia del número de bobina, 1 para primario y 
% 2 para secundario i_nCond, nos permite tener constancia del número de 
% conductor
for nB=1:n_bobinas
    % Parte negativa del eje x
    for i_nCond=0:(nCond(nB)/2)
        xI_N(i_nCond+1,nB)=(-xMaxCond(nB)+xDeltaCond(nB)*i_nCond);
    end
    % Parte positiva del eje x
    for i_nCond=(nCond(nB)/2):(nCond(nB)-1)
        xI_N(i_nCond+1,nB)=(xMaxCond(nB)-xDeltaCond(nB)*((nCond(nB)-1)-i_nCond));
    end
    % Colocamos en una matriz del mismo tamaño que la de Intensidad la
    % posición de cada conductor en las abcisas, no tenemos en cuenta su
    % ordenada
end
% xI_N


%% Calculo de las ordenadas y en mm para cada nucleo en iteración: y_NCO

if nNucleos>0
    % "Altura" de cada núcleo en cada iteración
    y_NCO=zeros(nNucleos,nIteraciones);

    % Si solo hay un núcleo no se pueden realizar iteraciones, solo se
    % realizaría un "espejo"
    if nNucleos==1
        y_NCO(1,1)=yNucleo(1);
        % Si es hay más núcleos tomo la distancia entre ambos y con ellos voy
        % distribuyendo las distintas líneas de espejo
    elseif nNucleos==2
        deltaNucleo=abs(yNucleo(1)-yNucleo(2));
        % Espejos reciprocos
        for iter=1:(nIteraciones+1)
            % preparo la posibilidad de que el espejo en yNucleo(1) este por
            % encima de yNucleo(2)
            if yNucleo(1)<yNucleo(2)
                y_NCO(1,iter)=yNucleo(1)-(iter-1)*deltaNucleo;
                y_NCO(2,iter)=yNucleo(2)+(iter-1)*deltaNucleo;
            elseif yNucleo(1)>yNucleo(2)
                y_NCO(1,iter)=yNucleo(1)+(iter-1)*deltaNucleo;
                y_NCO(2,iter)=yNucleo(2)-(iter-1)*deltaNucleo;
            end
        end
    end
    % y_NCO
end


%% Calculo de las ordenadas y en mm para cada conductor en iteración: y_N

% "Altura" de cada grupo de conductores en cada iteración para tanto el
% núcleo 1 como el 2
y_N=zeros(n_bobinas,nIteraciones+1,nNucleos);

% Opción de espejos reciprocos
for nN=1:nNucleos
    % Añado en la iteración 0, esto son los conductores reales
    iter=1;
    for nB=1:n_bobinas
        y_N(nB,iter,nN)=yCond(nB);
    end
    % Añado posteriormente las iteraciones apropiadas y calculo su ordenada
    % a partir del nucleo iterado correspondiente
    for iter=2:nIteraciones+1 
        for nB=1:n_bobinas
            y_N(nB,iter,nN)=y_N(nB,iter-1,nN)+2*(y_NCO(nN,iter-1)-y_N(nB,iter-1,nN));
        end
    end
end
% y_N


%% Obtención de I completa

% Variable en la que realmacenar las intentidades
I2=zeros(max(nCond),n_bobinas);

% Las psoiciono de manera que cada conductor tenga de manera simétrica
% respecto del origen otro de valor igual y opuesto 
for nB=1:n_bobinas
    % Intensidades en la parte negativa del eje x
    for iC=1:(nCond(nB)/2)
        I2(iC,nB)=-I((nCond(nB)/2+1)-iC,nB);
    end
    % Parte positiva del eje x
    for iC=(nCond(nB)/2+1):nCond(nB)
        I2(iC,nB)=I(nCond(nB)-iC+1,nB);
    end
end
% I2


%% Calculo del campo H 

% Calculamos en cada punto H el valor que ejerce cada agrupación de
% conductores
H_teorico=zeros(nPasos,max(nCond),n_bobinas,nIteraciones+1,nNucleos);

% Aplicamos la fórmula del campo H apropiada para obtener la influencia de
% cada conductor en la ordenada del conductor 1
for n=1:nPasos
    for nB=1:n_bobinas
        for iC=1:nCond(nB)

            %% Calculo del campo H en iteración 0
            iter=1;
            nN=1;
            % Si están el la misma ordenada y que el conductor 1
            if(yCond(nB) == yCond(1))
                %Conductor real propio
                if abs(x_N(n)-xI_N(iC,nB))<(dCond(nB)/2)
                    H_teorico(n,iC,nB,iter,nN)=I2(iC,nB)*(x_N(n)-xI_N(iC,nB))/(0.5*pi*(dCond(nB)^2));
                else
                    H_teorico(n,iC,nB,iter,nN)=I2(iC,nB)/(2*pi*(x_N(n)-xI_N(iC,nB)));
                end
            % Si no lo están se aplica la fórmula general
            else

                %
                xDelta=x_N(n)-xI_N(iC,nB);
                yDelta=y_N(nB,iter,nN)-yCond(1);
                %
                cociente=2*pi*(xDelta^2 + yDelta^2);
                H_teorico(n,iC,nB,iter,nN)=I2(iC,nB)*complex(xDelta,yDelta)/cociente;
            end

            %% Calculo del campo H en otras iteraciones
            if nIteraciones>0
                for iter=2:(nIteraciones+1)
                    % Calculamos en cada punto H el valor que ejerce cada agrupación de
                    % conductores
                    if nNucleos == 1
                        %
                        xDelta=x_N(n)-xI_N(iC,nB);
                        yDelta=y_N(nB,iter,nN)-yCond(1);
                        %
                        cociente=2*pi*(xDelta^2 + yDelta^2);
                        H_teorico(n,iC,nB,iter,nN)=I2(iC,nB)*complex(xDelta,yDelta)/cociente;
                    elseif nNucleos == 2
                        for nN=1:nNucleos
                            %
                            xDelta=x_N(n)-xI_N(iC,nB);
                            yDelta=y_N(nB,iter,nN)-yCond(1);
                            %
                            cociente=2*pi*(xDelta^2 + yDelta^2);
                            H_teorico(n,iC,nB,iter,nN)=I2(iC,nB)*complex(xDelta,yDelta)/cociente;
                        end
                    end
                end
            end

        end
    end
end


%% Suma de los campos H

% Variable en la que sumamos la influencia de cada grupo al campo H total
H_total=zeros(nPasos);

for nB=1:n_bobinas
    for nN=1:nNucleos
        for iter=1:nIteraciones+1
            H_total=H_total+sum(H_teorico(:,:,nB,iter,nN),2);
        end
    end
end

H_final=H_total(:,1);
     



%% *************************** Fin del programa ***************************












%% Campos H desagregados
% Debe estar comentado, sirve para depurar errores y obtener la
% represntación gráfica

% data=readtable('B06_2core2wire.csv');
% %Renombramos las variables que exportamos de Ansys
% H_1000Hz = data.Mag_H_kA_per_m__Freq__1MHz_Phase__0deg_;
% x = data.Distance_mm_-150;

% data=readtable('B07_2core2wire180.csv');
% %Renombramos las variables que exportamos de Ansys
% H_1000Hz = data.Mag_H_kA_per_m__Freq__1MHz_Phase__0deg_
% x = data.Distance_mm_-150;

% data=readtable('B08_2core2wire180100.csv');
% %Renombramos las variables que exportamos de Ansys
% H_1000Hz = data.Mag_H_kA_per_m__Freq__1MHz_Phase__0deg_;
% x = data.Distance_mm_-150;

% figure 
% hold on
% for nB=1:n_bobinas
%     for nN=1:nNucleos
%         for iter=1:nIteraciones+1
%             nB
%             nN
%             iter
%             y_N(nB,iter,nN)
%             sum(H_teorico(1,:,nB,iter,nN),2)
%             plot(real(sum(H_teorico(:,:,nB,iter,nN),2)));
% %             plot(imag(sum(H_teorico(:,:,nB,iter,nN),2)));
%         end
%     end
% end
% plot(abs(H_total));
% plot(H_1000Hz,'k-.');


%% Solicitud de datos
% Actualmente, todo se introduce como parametro a la función

% if (N1 ~= 0) && (nCond_N1 ~= 0)
%     % Preguntamos los valores de la intensidad en la parte negativa del eje X
%     disp('Introduzca las intensidades de cada conductor en la bobina')
%     disp('PRIMARIA dispuestas en la parte NEGATIVA de las ordenadas,')
%     disp('de menor a mayor:')
%     for nCond_i=1:nCond_N1
%         %disp(['Conductor: ',nCond_i])
%         I_N(nCond_i,1)=input(['Conductor ',int2str(nCond_i),': '])
%     end
% end
% if (N2 ~= 0) && (nCond_N2 ~= 0)
%     % Pedimos las intensidades para los conductores para el lado positivo
%     disp('Introduzca las intensidades de cada conductor en la bobina')
%     disp('PRIMARIA dispuestas en la parte POSITIVA de las ordenadas,')
%     disp('de menor a mayor igualmente:')
%     for nCond_i=(nCond_N2+1):(2*nCond_N2)
%         %disp(['Conductor: ',nCond_i])
%         I_N(nCond_i,2)=input(['Conductor ',int2str(nCond_i),': '])
%     end
% end


%% Trabajo en progreso
% % Comprobación de que no se superpongan conductores
% 
% 
% % Comprobación de que no hay conductores que atraviesen por el eje de
% % estudio por un lugar distinto del diametro
% 
% 
% % Comprobación de que los conductores y los núcleos están dispuestos
% % coherentemente entre sí
% if nNucleos==1 && n_bobinas>1
%     for i=2:n_bobinas
%         for n=1:nNucleos
%             if (yCond(1)-yCond(i))>(yCond(1)-nNucleos(n))
%                 warning('Imposible de resolver, núcleo entre los conductores');
%                 return;
%             end
%         end
%     end
% end
% if nNucleos>1
% 
% for n=2:nNucleos
%     if nNucleos
% for i=1:n_bobinas
%     for n=1:nNucleos
%         if yCond(i)>