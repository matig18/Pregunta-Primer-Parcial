% Consigna Primer Parcial - El Libano
% Matias Giorgio

%{
Como leer las variables:
variable_pais
e = Estados Unidos
l = Libano
%}

cd 'Desarrollo Economico/Consigna Parcial'
data_l = xlsread('Milagros_Desastres_Data.xlsx', 'Lebanon');
data_eeuu = xlsread('Milagros_Desastres_Data.xlsx', 'EEUU(filtrado)');

% Definimos parametros:
alpha = 0.6;
delta = 0.04;
g = 0.02;
gamma = 0.95;

% Alpha surge de (1 - labor share del Libano) por error de medicion estimamos que el alpha es menor a lo que dicen los datos.
% SOURCE: https://ourworldindata.org/grapher/labor-share-of-gdp

%% EEUU %%

% Poblacion en Estados Unidos
pop_e = data_eeuu(:,4);


% Tasa de crecimiento poblacional
for i = 2:length(pop_e);
    n_e(i, 1) = (pop_e(i) - pop_e(i-1)) / pop_e(i-1);
end


% Tasa de ahorro
cda_e = data_eeuu(:,8);
ccon_e = data_eeuu(:,7);
rgdpo_e = data_eeuu(:,2);
s_e = (cda_e-ccon_e) ./ rgdpo_e;

% Capital humano
hc_e = data_eeuu(:,6);

% Producto per capita (trabajadores)
emp_e = data_eeuu(:,5);
y_e = rgdpo_e ./ emp_e;

% Calculamos A
cn_e = data_eeuu(:,9);
k_e = cn_e ./ emp_e;
A_e = ( (y_e) ./ ((k_e).*((hc_e)).^(1-alpha)) ) .^ (1/(1-alpha));

%% LIBANO %%


pop_l = data_l(:,4);

% Tasa de crecimiento poblacional
for i = 2:length(pop_l);
    n_l(i, 1) = (pop_l(i) - pop_l(i-1)) / pop_l(i-1);
end

%n_l_avg = mean(n_l(:,:));

% Capital
cn_l = data_l(:,12);

% Tasa de ahorro
cda_l = data_l(:,9);
ccon_l = data_l(:,8);
rgdpo_l = data_l(:,3);
s_l = (cda_l-ccon_l) ./ rgdpo_l;

%s_l_avg = mean(s_l);

% Capital humano
hc_l = data_l(:,7);
dif_hc_l = hc_l - hc_e(21:70);

% Producto per capita (trabajadores)
emp_l = data_l(:,5);
y_l = rgdpo_l ./ emp_l;

% Producto relativo a EEUU
y_hat_l = y_l ./ y_e(21:70);



%%% PREDICCION SOLOW PARA EL LIBANO %%%

% Calculamos A
k_l = cn_l ./ emp_l;
A_l = ( (y_l) ./ ((k_l).*((hc_l)).^(1-alpha)) ) .^ (1/(1-alpha));

% Calculamos ctfp
%ctfp_l = A_l ./ A_e(21:70);
denom = A_l + A_e(21:70,1);
ctfp_l = A_l ./ denom;


%ctfp_l_avg = mean(ctfp_l);

% y_hat estimado por Solow
s_e_avg = mean(s_e(21:70));
n_e_avg = mean(n_e(21:70));

% Prediccion final del modelo de Solow:
% y_hat_solow_l = ctfp_l_avg * exp(dif_hc_l_avg) * (s_l_avg/s_e_avg)^(alpha/(1-alpha)) * ((delta + n_e_avg + g)/(delta + n_l_avg + g))^(alpha/(1-alpha));




%% Graficos %%

%{
figure(1)

subplot(2, 2, 1)
plot(data_l(:,1), y_l ./ y_e(21:70), '-b', 'LineWidth', 0.9)
title('Producto per capita del Libano relativo a EEUU entre 1970 y 2019')
xlabel('Fecha')
ylabel('y_L / y_E  (%)')
axis([1970 2019 0 1])
grid on

subplot(2, 2, 2)
plot(data_l(:,1), ctfp_l, '-b', 'LineWidth', 0.9)
title('Productividad relativa entre el Libano y EEUU entre 1970 y 2019')
xlabel('Fecha')
ylabel('CTFP relativo del Libano (%)')
axis([1970 2019 0 1])
grid on

subplot(2, 2, 3)
plot(data_l(:,1), s_l ./ s_e(21:70,1), '-b', 'LineWidth', 0.9)
title('Fraccion del ingreso dedicada a la inversion relativa de 1970 a 2019')
xlabel('Fecha')
ylabel('Inversion relativa (s_L / s_E)')
axis([1970 2019 0 2])
grid on

subplot(2, 2, 4)
plot(data_l(:,1), hc_l ./ hc_e(21:70,1), '-b', 'LineWidth', 0.9)
title('Capital humano relativo entre El Libano y EEUU de 1970 a 2019')
xlabel('Fecha')
ylabel('Capital humano relativo (hc_L / hc_E)')
axis([1970 2019 0 1])
grid on
%}

%% Solow con implementacion de tecnologia %%

m_l = data_l(28:50,52);
m_e = data_l(22:50,53);
h_l = data_l(28:50,54);
h_e = data_l(22:50,55);

% Calcular mu
x = data_l(end-4:end, 1);
y = hc_l(end-4:end, 1) ./ hc_e(end-4:end, 1);
lm = fitlm(x, y);
mu_e = 1250;
mu_l = lm.Coefficients.Estimate(2) / (hc_l(50,1) * (A_l(50,1) * h_l(end, 1))^gamma);


% Datos de 2015 a 2019
num1 = A_l(46:50,1) ./ A_e(46:50,1);
num2 = (1 + m_l(end-4:end) ./ h_l(end-4:end)) * mu_e ./ (1 + m_e(end-4:end) ./ h_e(end-4:end));
num3 = (mu_l .* (hc_l(end-4:end) ./ hc_e(end-4:end)));
num4 = (s_l(end-4:end) ./ (n_l(end-4:end) + delta + g)) ./ (s_e(end-4:end) ./ (n_e(end-4:end) + delta + g));
y_hat_solow = (num1) .* (num2) .* (num3).^(1/gamma) .* (num4).^(alpha/(1-alpha));
y_hat_solow_avg = mean(y_hat_solow)



y_relativo = y_l ./ y_e(21:70);
y_relativo_avg = mean(y_relativo);

%% Inciso C %%

%{
smoothed_data = smooth(data_l(:,1), y_l ./ y_e(21:70), 8);
plot(data_l(:,1), smooth(data_l(:,1), y_l ./ y_e(21:70), 8), '-r', 'LineWidth', 1.2)
hold on
scatter(1990, 0.309, 'black', 'filled');
title('Media movil del producto per capita del Libano relativo a EEUU')
xlabel('Fecha')
ylabel('y_L / y_E  (%)')
axis([1970 2019 0 1])
grid on
label = sprintf('(%.0f, %.3f)', 1990, 0.309);
text(1991, 0.33, label, 'Color', 'black', 'FontSize', 12);

%}

%% Consistencia temporal de predicci?n de Solow %%

%{
% Datos de 1970 a 2019
num11 = A_l(28:50,1) ./ A_e(48:70,1);
num22 = (1 + m_l ./ (hc_l(28:50,1) ./ hc_e(48:70,1))) * mu_e ./ (1 + m_e(7:29,1));
num33 = (mu_l .* (hc_l(28:50,1) ./ hc_e(48:70,1)));
num44 = (s_l(28:50,1) ./ (n_l(28:50,1) + delta + g)) ./ (s_e(48:70,1) ./ (n_e(48:70,1) + delta + g));
y_hat_solow_ALL = (num11) .* (num22) .* (num33).^(1/gamma) .* (num44).^(alpha/(1-alpha));
y_hat_solow_ALLavg = mean(y_hat_solow_ALL);

plot(data_l(28:50,1), y_hat_solow_ALL, '-b', 'LineWidth', 1.2)
hold on
plot(data_l(28:50,1), y_relativo(28:50,1), '-r', 'LineWidth', 1.2)
axis([1997 2004 0 0.55])
grid on
title('Prediccion de Solow entre 1997 y 2004')
xlabel('Fecha')
ylabel('Producto per capita relativo (%)')
legend('Prediccion','Valor real')
set(legend, 'FontSize', 15)
%}

%{
% 28 a 50. 1997 a 2019
m_over_h_l = m_l ./ h_l
m_over_h_e = m_e(7:29,1) ./ h_e(7:29,1)
plot(data_l(28:50,1), m_over_h_l, '-b', 'LineWidth', 0.9)
hold on
plot(data_l(28:50,1), m_over_h_e, '-r', 'LineWidth', 0.9)
legend('Libano','EEUU')
axis([1997 2019 0.9 1.8])
xlabel('Fecha')
ylabel('m / h')
title('Evolucion de cociente entre variedad de productos importados y exportados para el Libano y EEUU')
grid on
set(legend, 'FontSize', 15)
%}







