clear all;
clc
%% ================================================ Setup system ==============================================      
% Two different dataset for testing
identType = 3;                                                                  
if identType == 1
    load('.\data\x')
    load('.\data\u')
    load('.\data\d')
    load('.\data\d_r')
    load('.\data\d_w')
    load('.\data\nominal parameters\Kt')
    load('.\data\nominal parameters\a33','a33');    
    load('.\data\nominal parameters\a43','a43');    
    load('.\data\nominal parameters\a44','a44');  
    %load('.\data\nominal parameters\b31','b31');    
    %load('.\data\nominal parameters\b41','b41');  
elseif identType == 2
    load('.\data\onoff\x')
    load('.\data\onoff\u')
    load('.\data\onoff\d')
    load('.\data\onoff\d_r')
    load('.\data\nominal parameters\Kt')
    load('.\data\nominal parameters\onoff\a33','a33');    
    load('.\data\nominal parameters\onoff\a43','a43');    
    load('.\data\nominal parameters\a44','a44');  
    load('.\data\nominal parameters\\onoff\b31','b31');    
    load('.\data\nominal parameters\onoff\b41','b41');  
elseif identType == 3
    load('.\data\random\x')
    load('.\data\random\u')
    load('.\data\random\d')
    load('.\data\random\d_r')
    load('.\data\nominal parameters\Kt')
    load('.\data\nominal parameters\random\a33','a33');    
    load('.\data\nominal parameters\random\a43','a43');    
    load('.\data\nominal parameters\random\a44','a44');  
    load('.\data\nominal parameters\random\b31','b31');    
    load('.\data\nominal parameters\random\b41','b41');  
    load('.\data\nominal parameters\random\c3','c3');    
    load('.\data\nominal parameters\random\c4','c4'); 
end

% discard p2 and p3 states from dataset
x = [x(1,:); x(2,:); x(3,:); x(6,:)];

% change the combined disturbance to the separated rain disturbance
for i = 1:size(d_r,2)
    if d_r(1,i) <= 0.15
        d_r(1,i) = 0;
    end
end

% Identification and data sampling properties
t_resample = 20;
dt_original = 0.5;
data_timeUnit = 60;                                                             % flow in [60s]
dt = dt_original*t_resample/60;                                                 % 10 [min] for sysID

% Dimensions
Nxt = 2;                                                                        % tank state size
Nxp = 2;                                                                        % pipe states size
Nx = Nxt + Nxp;                                                                 % full state size

% Nominal dynamics - tanks
At = [(eye(Nxt)), zeros(Nxp,Nxp)]; 
Bt = -diag([dt/Kt, dt/Kt]); 
Et = [diag([dt/Kt dt/Kt]), zeros(Nxt,1)];

% Nominal dynamics - pipes
a33 = 0;                                                                        % not used: single flow to level mapping
a43 = 0;
a44 = 0;
% b31 = 0;
% b41 = 0;
Ap = [0,0,a33, 0; 
      0,0,a43, a44];
Bp = [b31, 0; b41, 0];
Ep = zeros(2,3);

d_rain_enabler = 1;                                                             % if true, only rain is the disturbance
if d_rain_enabler == 1
    Et = zeros(2,3);
    d = d_r;
end

% Nominal dynamics - combined
A = [At; Ap];
B = [Bt; Bp];
E = [Et; Ep];
f = A*x(:,1:end-1) + B*u(:,1:end-1) + E*d(:,1:end-1) + [0;0;c3;c4];

% Build residuals
Bd = eye(Nxt + Nxp);                                                            % mapping matrix
y_unfiltered = pinv(Bd) * (x(:,2:end) - f);                                     % residuals (output set)

% Remove outliers in last pipe state
y_temp1(4,:) = filloutliers(y_unfiltered(4,:),'previous','mean');
y_temp2(4,:) = filloutliers(y_temp1(4,:),'previous','mean');
y_unfiltered(4,:) = y_temp2(4,:);
for i = 1:Nx
    y(i,:) = (y_unfiltered(i,:));                                               % remove outliers 
end

y(1:Nxt,:) = y(1:Nxt,:) + 0.005*randn(Nxt,size(y,2));                           % Add noise to tank residuals
y(Nxt+1:Nx,:) = y(Nxt+1:Nx,:) + 0.00075*randn(Nxp,size(y,2));                   % Add noise to pipe residuals

% Create time input
period = 115;                                                                   % 1 day in steps: 115*
t = 1:size(x,2);
offset = 13;
t_mod = mod(t-offset,period)./period;
z = [x; u; d; t_mod];                                                           % Training set

% Make mapping of training set for each GP
training_set_mapping;

num_x = [0,1,1,2];                                                              % number of state regressor in residuals

% Sanity check - residuals 
plotEnabler = 1;
if plotEnabler == 1
figure                                                                          % tank states
for i = 1:Nxt
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

figure                                                                          % pipe states
for i = Nxt+1:Nxt+Nxp
    plot(y(i,:))
    hold on
end
plot(zeros(size(y,2),1),'black--')
title('Residuals for pipe states','interpreter','latex')
leg = legend('$[y]_{3}$','$[y]_{4}$','zero');
set(leg,'Interpreter','latex');
xlabel('Time [10 s]','interpreter','latex')
ylabel('Level [$dm$]','interpreter','latex')
grid on
end
%% =============================================== GP training  ==============================================  
gps = cell(Nx,1);                                                               % init gps
n = 1200; % ARD combined                                                        % training set length
sigma0 = std(y');                                                               % Initialize signal variance

offset = 125;%10 ;%+ 1613;

opts = statset('fitrgp');
opts.TolFun = 1e-2;                                                             % convergance tolerance
tic 
for i = 3:4%1:Nx
    gps{i} = fitrgp((C{i}*z(:,1 + offset: n + offset))',y(i,1 + offset: n + offset)','OptimizeHyperparameters','auto',...
        'KernelFunction','ardsquaredexponential','BasisFunction','none','HyperparameterOptimizationOptions',...
        struct('UseParallel',true,'MaxObjectiveEvaluations',40,'Optimizer','bayesopt'),'OptimizerOptions',opts,...
        'Sigma',sigma0(i),'Standardize',1,'Verbose',2,'Optimizer','quasinewton');
end
toc 
% 'FitMethod','fic'
%% =============================================== Plot results ==============================================  
plotter;

%% ============================================= Save GP object ==============================================  
%save('.\GPs\gps_onoff')
%save('.\GPs_short\gps')
%load('.\GPs\gps_onoff')

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

%% Save hyperparameters
%save('.\GP_parameters','sigma_f','inv_sigma_L','sigma','z_train','y_train','t_mod','C','Beta')

%% Test on validation data

num_test = 4;
gp1 = gps{num_test};
[respred1,~,ress_ci] = predict(gp1, (C{num_test}*z(:,n:n+np))');

figure
plot(x(num_test,999:end))
hold on
plot(respred1' + f(num_test,999:end))
%  
