%% control_specs.m
% """
% Specifies all the control and model specs
% """

% Seed random generator
rng('default');
rng(1);

addpath('.\control');
addpath('.\plotter');

%% Basic properties for simulator
Nxt = 2;                            % number of tank states
Nxp = 1;                            % number of channel states 
Nxp_sim = 4;                        % In simulation we have Nxt = 2 and Nxp = 4
Nx = Nxt + Nxp;                     % all states
Nu = 2;                             % number of inputs
Ny = Nx;                            % number of GP residuals
NP = 3 + 2;                         % number of channel parameters 
ND = 3;                             % number of disturbances

load('parameters\P_pipe_min_v2')    % load pipe parameters for simulator
load('parameters\Kt')               % load tank parameters for GP
load('.\parameters\a33','a33');     % load pipe parameters for GP
load('.\parameters\a43','a43');    
load('.\parameters\a44','a44');  
% load('.\parameters\b31','b31');    
% load('.\parameters\b41','b41');

load('.\parameters\test\b31','b31'); 
load('.\parameters\test\b41','b41'); 
load('.\parameters\test\c3','c3'); 
load('.\parameters\test\c4','c4'); 

c4 = 0;
b41 = 0;

P_sim = [P_pipe_min_v2, Kt, Kt]';   % all sim parameters

%% Load forecasts
load('D_sim')
load('D_sim_rain')

%% GP dynamics properties
M  = 60;                 % 70 works           % dimesnion of K_ZZ covariance matrix used in MPC
Nz = Nx + Nu + ND + 1;              % dimension of the training set 

% Load GP object (hyperparameters, mappings, training data)
%GP = load('.\parameters\GP_parameters.mat'); 
GP = load('.\parameters\test\GP_parameters.mat'); 

%% 

% level offset 
h_lift = 2;                         % [dm]

% Input constraints                 % [l/dm]  
u1_on  = 6 + 0.5;                   %6.5                                          
u1_off = 3.4;                         
u2_on  = 14;                      %14.5   
u2_off = 5.4;         

% Tank constraints                  % [dm]
max_t1 = 7;       
min_t1 = 1.8 + h_lift;             
max_t2 = 6.5;     
min_t2 = 2.3 + h_lift;

% Pipe constraints                  % [dm]
h_p_max = 0.4;
h_p_min = 0.00001;

% Tank safety region
max_t1_op = 5.5-0.3;                % [dm]
min_t1_op = 4;
max_t2_op = 5.5-0.3;
min_t2_op = 4.5;

%% MPC specs
t_resample = 20;                    % Resample raw data - conversion between simulator/MPC time steps
Hp = 15;                            % 40 for Pde mpc
dt_original = 0.5;                  % In lab we sample with dt = 0.5 [s]
data_timeUnit = 60;                 % MPC is running with T = 60 [s] = 1 [min]
dt_MPC = dt_original*t_resample/data_timeUnit;

lam_g = 1;                          % warm start - Lagrange multiplier initializer
x_init = 0.01;%0.01;  

% Initial conditions
t_init = 150;
X_sim(1,t_init) = 2.8 + h_lift;              % init. tank1 state [m^3]
X_sim(2,t_init) = 2.8 + h_lift;              % init. tank2 state [m^3]                                                                     
X_sim(Nxt+1:Nxt+Nxp_sim,t_init) = 0.001;     % init. pipe states [m]
sigma_X0_sim = zeros(Nx,Nx);                 % zero initial variance
[D_sim_sim, D_sim_sim_f] = forecast(D_sim_rain,t_init,Hp);
X_sim_GP(:,t_init) = [X_sim(1,t_init); X_sim(2,t_init); X_sim(6,t_init)];
u_prev = [0;0];                     % init. integral action

Z_train_subset = GP.z_train(:,t_init:t_init+M-1);   % Initialize the training subset randomly (first M entry) GP.z_train(:,randperm(length(GP.z_train(1,:)),M));%
Y_train_subset = GP.y_train(:,t_init:t_init+M-1);   %GP.y_train(:,randperm(length(GP.y_train(1,:)),M));%
K_xx_builder;                                   % build initial K_xx from historic MxM training points

%% Fixed disturbance forecast

D_sim_rain_uncertain = abs(D_sim_rain + randn(3,length(D_sim_rain))*0);   %0.5
