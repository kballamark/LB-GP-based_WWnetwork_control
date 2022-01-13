clear all;
clc
%% ================================================ Setup system ==============================================      
% load time series
load('.\data\onoff\x_full')
load('.\data\onoff\u_ref_full')
load('.\data\onoff\d_r_full')

% load nominal parameters
load('.\parameters\nominal\b31')
load('.\parameters\nominal\b41')
load('.\parameters\nominal\c3')
load('.\parameters\nominal\c4')
load('.\parameters\nominal\Kt')

b41 = 0;
c4 = 0;

%%

% discard p2 and p3 states from dataset
x = [x(1,:); x(2,:); x(3,:); x(6,:)];

% outlier removal
x(3,:) = filloutliers(x(3,:),'nearest','movmean',200);
x(3,:) = filloutliers(x(3,:),'nearest','movmean',200);
x(4,:) = (filloutliers(x(4,:),'nearest','movmean',200))';

% smooth pipe level signals
x(3,:) = smooth(smooth(x(3,:)));
x(4,:) = smooth(x(4,:));

% remove negative values from d_r
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
Et = zeros(2,3);

% Nominal dynamics - pipes
a33 = 0;                                                                        % not used: single flow to level mapping
a43 = 0;
a44 = 0;
Ap = [0,0,a33, 0; 
      0,0,a43, a44];
Bp = [b31, 0; b41, 0];
Ep = zeros(2,3);

d = d_r;
d(:,end) = [];

% Nominal dynamics - combined
A = [At; Ap];
B = [Bt; Bp];
E = [Et; Ep];
f = A*x(:,1:end-1) + B*u(:,1:end-1) + E*d(:,1:end-1) + [0;0;c3;c4];

% Build residuals
Bd = eye(Nxt + Nxp);                                                            % mapping matrix
y = pinv(Bd) * (x(:,2:end) - f);                                                % residuals (output set)

% Remove outlier from residuals
y(2,:) = filloutliers(y(2,:),'previous','mean');
y(2,:) = filloutliers(y(2,:),'previous','mean');
y(1,2500) = 0;

% Remove NaN
y(2,1) = y(2,2);

% add noise (only on simulation data)
y(1:Nxt,:) = y(1:Nxt,:); %+ 0.005*randn(Nxt,size(y,2));                           % Add noise to tank residuals
y(Nxt+1:Nx,:) = y(Nxt+1:Nx,:); %+ 0.00075*randn(Nxp,size(y,2));                   % Add noise to pipe residuals

% Create time input
period = 115;                                                                   % 1 day in steps: 115*
t = 1:size(x,2);
offset = 13;
t_mod = mod(t-offset,period)./period;
z = [x; u; d; t_mod];                                                           % Training set

% Make mapping of training set for each GP
training_set_mapping;

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

% Moving average filtering of residuals
y(1,:) = smooth(y(1,:));
y(2,:) = smooth(y(2,:));

%% =============================================== GP training  ==============================================  
gps = cell(Nx,1);                                                               % init gps
n = 1500; % ARD combined                                                        % training set length
sigma0 = std(y');                                                               % Initialize signal variance

offset = 30;%10 ;%+ 1613;

opts = statset('fitrgp');
opts.TolFun = 1e-2;                                                             % convergance tolerance
tic 
for i = 1:Nx
    gps{i} = fitrgp((C{i}*z(:,1 + offset: n + offset))',y(i,1 + offset: n + offset)','OptimizeHyperparameters','auto',...
        'KernelFunction','ardsquaredexponential','BasisFunction','none','HyperparameterOptimizationOptions',...
        struct('UseParallel',true,'MaxObjectiveEvaluations',30,'Optimizer','bayesopt'),'OptimizerOptions',opts,...
        'Sigma',sigma0(i),'Standardize',1,'Verbose',2);
end
toc 
% 'FitMethod','fic'
%% =============================================== Plot results ==============================================  
plotter;

%% ============================================= Save GP object ==============================================  
%save('.\GPs\gps')
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
save('.\GP_parameters','sigma_f','inv_sigma_L','sigma','z_train','y_train','t_mod','C','Beta')

%% Test on validation data

num_test = 1;
gp1 = gps{num_test};
[respred1,~,ress_ci] = predict(gp1, (C{num_test}*z(:,n:n+np))');

figure
plot(x(num_test,1:end))
hold on
plot(respred1' + f(num_test,999:end))
%  
