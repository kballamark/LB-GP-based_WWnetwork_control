clear all;            
clear path;
clc;  
%% ================================================ Prepare data ==============================================

identType = 3;
if identType == 1
    % closed loop MPC data
    load('.\data\x')
    load('.\data\u')
    load('.\data\d')
    load('.\data\d_r')
    load('.\data\d_w')
    x = x(:,1:end);
    u = u(:,1:end);
    d = d(:,1:end);                                                                 % Load simulation data 
    % onoff data
elseif identType == 2
    load('.\data\onoff\x')
    load('.\data\onoff\u')
    load('.\data\onoff\d')
    load('.\data\onoff\d_r')
    x = x(:,1:end);
    u = u(:,1:end);
    d = d(:,1:end); 
    % onoff data with random input
elseif identType == 3
    load('.\data\random_inputs\x')
    load('.\data\random_inputs\u')
    load('.\data\random_inputs\d')
    load('.\data\random_inputs\d_r')
    x = x(:,1:end);
    u = u(:,1:end);
    d = d(:,1:end); 
end

%%
startData = 100;
endData_sysID = size(x,2)-startData;      
Nx = 2;

x3 = x(3,startData:endData_sysID);
x4 = x(4,startData:endData_sysID);
u1 = u(1,startData:endData_sysID);
u2 = u(2,startData:endData_sysID); 

%% ============================================ Idata object ================================================ 
Ts_data = 1;                                                                    % [10s] in the lab. Dataset is already resampled with t_step = 20 
input = [u1; u2]';
output = [x3; x4]';

data = iddata(output,input,Ts_data);                                            % (y,u,Ts) order
data.TimeUnit = 'seconds';

%% ===================================================== Model ============================================
modelName = 'model_disc';
Ts_model = 1;                                                                   % 0 - continuous model, 1,2,.. - discrete model 
order = [size(output,2) size(input,2) Nx];                                      % [Ny Nu Nx] order

a = [0.2, 0.1, 0.3];
b = [0.007, 0.005];
c = [0.001, 0.001];
params = [a, b, c];

initStates = 0.01*ones(Nx, 1);                                                  % assume 0 flow at t0
sys_init = idnlgrey(modelName, order, params, initStates, Ts_model);            % create nlgreyest object

sys_init.TimeUnit = 'seconds';
sys_init.Parameters(1).Name = 'a33';
sys_init.Parameters(2).Name = 'a43';
sys_init.Parameters(3).Name = 'a44';
sys_init.Parameters(4).Name = 'b31';
sys_init.Parameters(5).Name = 'b41';

sys_init.SimulationOptions.AbsTol = 1e-10;
sys_init.SimulationOptions.RelTol = 1e-8;
sys_init.SimulationOptions.Solver = 'FixedStepDiscrete';                        % ode4:4th order Runge-Kutte solver || ode1: Euler             

% sys_init.Parameters(1).Minimum = 0.001;     %sys_init.Parameters(1).Maximum = 0.5;   % parameter constraints
% sys_init.Parameters(2).Minimum = 0.001;     %sys_init.Parameters(2).Maximum = 10000;
% sys_init.Parameters(3).Minimum = 0.001;     %sys_init.Parameters(3).Maximum = 100;

% for i = 1:Nx
% sys_init.InitialStates(i).Minimum = 0.000001;                                   % States lower bound constraints
% sys_init.InitialStates(i).Maximum = 1;                                          % States upper bound constraints
% end

sys_init = setinit(sys_init, 'Fixed', false(Nx,1));

%% ============================================= Solver options ============================================
opt = nlgreyestOptions;
%Search methods: 'gn' | 'gna' | 'lm' | 'grad' | 'lsqnonlin' | 'auto'
opt.SearchMethod = 'gna'; 
opt.Display = 'on';
opt.SearchOption.MaxIter = 100;
%opt.SearchOption.Tolerance = 1e-15; 

%% =============================================== Estimation =============================================
tic 
sys_final = nlgreyest(data,sys_init, opt)                                       % Parameter estimation START

fprintf('\n\nThe search termination condition:\n')
sys_final.Report.Termination

estParams = [sys_final.Parameters(1).Value,...
             sys_final.Parameters(2).Value,...
             sys_final.Parameters(3).Value,...
             sys_final.Parameters(4).Value,...
             sys_final.Parameters(5).Value,...
             sys_final.Parameters(6).Value,...
             sys_final.Parameters(7).Value];

finalStates = sys_final.Report.Parameters.X0;                                   % estimated initial states
toc

%% ========================================== Estimated model ============================================
opt_init = simOptions('InitialCondition',initStates);                           % Simulate model on training data with initial parameters
y_init = sim(sys_init,data,opt_init);

opt_final = simOptions('InitialCondition',finalStates);                         % Simulate model on training data with estimated parameters
y_final = sim(sys_final,data,opt_final);

%% ========================================== Post - process ============================================
EstPlotter;

%% Save parameters

a33 = estParams(1);
a43 = estParams(2);
a44 = estParams(3);
b31 = estParams(4);
b41 = estParams(5);
c3 = estParams(6);
c4 = estParams(7);

save('.\parameters\a33','a33');    
save('.\parameters\a43','a43');    
save('.\parameters\a44','a44');  
save('.\parameters\b31','b31');    
save('.\parameters\b41','b41');  
save('.\parameters\c3','c3');    
save('.\parameters\c4','c4');  

%% Sanity check

test = [0,0,a33, 0; 0,0,a43, a44]*[x(1,:);x(2,:); x(3,:); x(4,:)] + [b31, 0; b41, 0]*u;

figure
plot(test(1,:))
figure
plot(test(2,:))
