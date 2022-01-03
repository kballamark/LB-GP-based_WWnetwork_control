%% Initialize_GP_MPC.m
% """
% Specifies all the control and model specs for building the optimization
% problem and loading time series and parameters.
% """

addpath('.\control');
addpath('.\parameters');

%% Dimension properties
Nxt = 2;                            % number of tank states
Nxp = 2;                            % number of pipe states 
Nx = Nxt + Nxp;                     % all states
Nu = 2;                             % number of inputs
Ny = Nx;                            % number of GP residuals
ND = 3;                             % number of disturbances
Nz = Nx + Nu + ND + 1;              % dimension of the training set (+1 counts for time)
M  = 60;                            % Number of points selected for GP prediction

%% Load parameters
load('parameters\nominal\Kt')                   % tank parameters
load('.\parameters\nominal\c3','c3');           % pipe parameters
load('.\parameters\test\nominal','c4'); 
GP = load('.\parameters\GP_parameters.mat');    % GP hyperparameters

%% Load time series
load('D_sim')                       % full combined WW + rain time series for generating disturbance
load('D_sim_rain')                  % rain forecast for predicting in control

%% Constraint values
% Input constraints                 % UNIT:[l/min]  
u1_on  = 6.5;                       % 6.5                                          
u1_off = 3.5;                       % 3.5  
u2_on  = 14;                        % 14  
u2_off = 5.4;                       % 5.4       
% Tank constraints                  % UNIT:[dm] 
max_t1 = 7;       
min_t1 = 3.8;             
max_t2 = 6.5;     
min_t2 = 4.3;
% Pipe constraints                  % UNIT:[dm] 
h_p_max = 0.4;
h_p_min = 0.00001;
% Tank safety region
max_t1_op = 5.2;                    % UNIT:[dm] 
min_t1_op = 4;
max_t2_op = 5.2;
min_t2_op = 4.5;

%% MPC specs
t_resample = 20;                    % Resample raw data - conversion between lab sampling/MPC time steps
Hp = 20;                            % 
dt_original = 0.5;                  % In lab we sample with dt = 0.5 [s]
data_timeUnit = 60;                 % second/minute conversion
dt_MPC = dt_original*t_resample/data_timeUnit;

lam_g = 1;                          % warm start - Lagrange multiplier initializer
x_init = 0.01;                      % state initializer

sigma_X0 = zeros(Nx,Nx);            % zero initial variance
u_prev = [0;0];                     % init. integral action

t_offset = 150;
Z_train_subset = GP.z_train(:,t_offset:t_offset+M-1);   % Initialize the training subset randomly (first M entry) GP.z_train(:,randperm(length(GP.z_train(1,:)),M));%
Y_train_subset = GP.y_train(:,t_offset:t_offset+M-1);   %GP.y_train(:,randperm(length(GP.y_train(1,:)),M));%

K_xx_builder;                       % build initial K_xx from historic MxM training points

GP_MPC_builder;                     % Build symbolic optimization problem

%% Stochastic disturbance forecast
%D_sim_rain_uncertain = abs(D_sim_rain + randn(3,length(D_sim_rain))*0.5);   %0.5