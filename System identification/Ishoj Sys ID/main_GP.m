clear all;
clc
%% ================================================ Setup system ==============================================      
load('.\data\basin_2')
load('.\data\manhole_1')
load('.\data\manhole_2')
load('.\data\manhole_3')
load('.\data\manhole_4')
load('.\data\manhole_5')
load('.\data\rain_table')
load('.\data\rain_ts')

%%
h_m1 = manhole_1.AI00_m_(1:2:end) - min(manhole_1.AI00_m_(1:2:end));
h_m2 = manhole_2.AI00_m_(1:2:end) - min(manhole_2.AI00_m_(1:2:end));  % discard
h_m3 = manhole_3.AI00_m_(1:2:end) - min(manhole_3.AI00_m_(1:2:end));
% h_m4 manipulation
h_m4 = manhole_4.AI00_m_(1:2:end) - min(manhole_4.AI00_m_(1:2:end));  % discard
h_m4(10750:20160) = h_m4(10749);
h_m4 = h_m4-min(h_m4);
h_m4 = [h_m4(1:68580); h_m4(68580)*ones(679,1); h_m4(68581:end)];
%
h_m5 = manhole_5.AI00_m_(1:2:end) - min(manhole_5.AI00_m_(1:2:end));
h_b2 = basin_2.AI00_m_(1:2:end) - min(basin_2.AI00_m_(1:2:end));
r    = [zeros(648,1); rain_ts.intensity];

T_up = 10;

for j = 1:(size(r,1)/T_up)
   r_temp(j) = sum(r(1+(j-1)*T_up:j*T_up)); 
end
r = r_temp'/T_up;


z = [h_m1(1:T_up:end)'; h_m3(1:T_up:end)'; h_m4(1:T_up:end)'; h_m5(1:T_up:end)'; h_b2(1:T_up:end)'; r'];
y = [h_m1(1:T_up:end)'; h_m3(1:T_up:end)'; h_m4(1:T_up:end)'; h_m5(1:T_up:end)'; h_b2(1:T_up:end)'];

% quick fix
y(3,6413) = 0.1169;

%%
Nx = 5;
% Make mapping of training set for each GP
training_set_mapping;

%%
% Sanity check 
plotEnabler = 1;
if plotEnabler == 1
figure                                                                          % tank states
for i = 1:5
    plot(y(i,:))
    hold on
end
plot(zeros(size(y,2),1),'black--')
title('Residuals for tanks','interpreter','latex')
leg = legend('$[y]_{1}$','$[y]_{2}$','zero');
set(leg,'Interpreter','latex');
xlabel('Time [10 s]','interpreter','latex')
ylabel('Level [dm]','interpreter','latex')
grid on
end
%% =============================================== GP training  ==============================================  
gps = cell(Nx,1);                                                               % init gps
n = 3452;%3452/2;       %******* Set this lower for less heavy computation **********   % training set length
sigma0 = std(y');                                                               % Initialize signal variance

offset = 1;

opts = statset('fitrgp');
opts.TolFun = 1e-2;                                                             % convergance tolerance
tic 
for i = 2%1:5
%     gps{i} = fitrgp((C{i}*z(:,1 + offset: n + offset))',y(i,1 + offset: n + offset)','OptimizeHyperparameters','all',...
%         'HyperparameterOptimizationOptions',...
%         struct('UseParallel',true,'MaxObjectiveEvaluations',40,'Optimizer','bayesopt'),'OptimizerOptions',opts,...
%         'Sigma',sigma0(i),'Standardize',1,'Verbose',2,'Optimizer','quasinewton');
    
    gps{i} = fitrgp((C{i}*z(:,1 + offset: n + offset))',y(i,1 + offset: n + offset)','OptimizeHyperparameters','auto',...
        'KernelFunction','ardsquaredexponential','BasisFunction','constant','HyperparameterOptimizationOptions',...
        struct('UseParallel',true,'MaxObjectiveEvaluations',30,'Optimizer','bayesopt'),'OptimizerOptions',opts,...
        'Sigma',sigma0(i),'Standardize',1,'Verbose',2,'Optimizer','quasinewton');
    
end
toc 
% 'FitMethod','fic'
%% =============================================== Plot results ==============================================  
plotter;

%% ============================================= Save GP object ==============================================  
%save('.\GPs\gps')
load('.\GPs\gps')        %*********** Just load this to get an already pre-trained instance ************

%% ====================================== Build & Save hyperparameters =======================================  
% Build sigma_L and sigma_f
sigma_f = zeros(Nx,1);                                                          % Build sigma_f vector 
inv_sigma_L = cell(Nx,1);                                                       % Build sigma_L vector (build inverse for control)

for i = 1:Nx 
    sigma_f(i) = gps{i}.KernelInformation.KernelParameters(end);
    inv_sigma_L{i} = inv(diag(gps{i}.KernelInformation.KernelParameters(1:end-1)));
end

for i = 1:Nx
    sigma(i) = gps{i}.Sigma;                                                    % Build sigma noise variance
end

% Build training dataset 
z_train = z;                                                                    % individual training set for each GP
y_train = y;                                                                    % individual residual set for each GP

% Build Beta offsets
for i = 1:Nx
   Beta(i,:) = gps{i}.Beta;                                                     % This is not used (equals to 0)
end

% Save hyperparameters
%save('.\GP_parameters','sigma_f','inv_sigma_L','sigma','z_train','y_train','t_mod','C')

%% Test on validation data

% num_test = 1;
% gp1 = gps{num_test};
% [respred1,~,ress_ci] = predict(gp1, (C{num_test}*z(:,n:n+np))');
% 
% figure
% plot(x(num_test,1500:end))
% hold on
% plot(respred1' + f(num_test,1500:end))
%  
