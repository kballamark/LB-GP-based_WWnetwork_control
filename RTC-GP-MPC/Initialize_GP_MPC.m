%% Initialize_GP_MPC.m
% """
% Specifies all the control and model specs for building the optimization
% problem and loading time series and parameters.
% """

clear all; clc;

addpath('.\control');
addpath('.\parameters');
addpath('.\time series');
addpath('.\tools');

%% ============================================ Dimension properties =============================
Nxt = 2;                            % number of tank states
Nxp = 2;                            % number of pipe states 
Nx = Nxt + Nxp;                     % all states
Nu = 2;                             % number of inputs
Ny = Nx;                            % number of GP residuals
ND = 3;                             % number of disturbances
Nz = Nx + Nu + ND + 1;              % dimension of the training set (+1 counts for time)
M  = 100;                            % Number of points selected for GP prediction

%% =============================================== Parameters ====================================
load('parameters\nominal\Kt')                   % tank parameters
load('.\parameters\nominal\c3','c3');           % pipe parameters
load('.\parameters\nominal\c4','c4'); 
load('.\parameters\nominal\b31','b31'); 
load('.\parameters\nominal\b41','b41'); 
GP = load('.\parameters\GP_parameters.mat');    % GP hyperparameters

%% =============================================== Time series ===================================
load('time series\disturbance forecast\D_sim')                       % full combined WW + rain time series for generating disturbance
load('time series\disturbance forecast\D_sim_rain')                  % rain forecast for predicting in control

%% ============================================== Constraint values ==============================
% Input constraints                 % UNIT:[l/min]  
u1_on  = 6.5;                       % 6.5                                          
u1_off = 3.5;                       % 3.5  
u2_on  = 14;                        % 14  
u2_off = 5.4;                       % 5.4       
% Tank constraints                  % UNIT:[dm] 
max_t1 = 6.8;                       % 6.9    
min_t1 = 4.2;             
max_t2 = 5.95;     
min_t2 = 4.3;
% Pipe constraints                  % UNIT:[dm] 
h_p_max = 0.4;
h_p_min = 0.00001;
% Tank safety region
max_t1_op = 5.6;                    % UNIT:[dm] 
min_t1_op = 4.4;
max_t2_op = 5.2;
min_t2_op = 4.5;

%% ========================================= Control specifications =============================
t_resample = 20;                    % Resample raw data - conversion between lab sampling/MPC time steps
Hp = 20;                            % 
dt_original = 0.5;                  % In lab we sample with dt = 0.5 [s]
data_timeUnit = 60;                 % second/minute conversion
dt_MPC = dt_original*t_resample/data_timeUnit;

lam_g = 1;                          % warm start - Lagrange multiplier initializer
x_init = 0.01;                      % state initializer

sigma_X0_init = zeros(Nx,Nx);       % zero initial variance
u_prev = [0;0];                     % init. integral action

t_offset = 150;
Z_train_subset = GP.z_train(:,t_offset:t_offset+M-1);   % Initialize the training subset randomly (first M entry) GP.z_train(:,randperm(length(GP.z_train(1,:)),M));%
Y_train_subset = GP.y_train(:,t_offset:t_offset+M-1);   %GP.y_train(:,randperm(length(GP.y_train(1,:)),M));%

[inv_K_xx_val,K_xx] = K_xx_builder(Z_train_subset,GP,Nx,M);     % build initial K_xx from historic MxM training points

GP_MPC_builder;                     % Build symbolic optimization problem

period = 115;                       % period of 1 Day in t_resample
t = 1:10000;                       % long time sequence
offset = 13;
Time = mod(t-offset,period)./period;

% QUICK FIX - Correct this !!!
GP.y_train = [GP.y_train, GP.y_train(:,end)];

GP.z_train(:,1:2:end) = [];
GP.y_train(:,1:2:end) = [];
%
% GP.z_train(:,1:2:end) = [];
% GP.y_train(:,1:2:end) = [];

%% Stochastic disturbance forecast
%D_sim_rain_uncertain = abs(D_sim_rain + randn(3,length(D_sim_rain))*0.5);   %0.5

D_sim(:,1:150*20) = [];
D_sim_rain(:,1:150*20) = [];

% % test for only rainy period
% D_sim(:,1:1350*20) = [];
% D_sim_rain(:,1:1350*20) = [];

%
D_sim(:,1:430*20) = [];
D_sim_rain(:,1:430*20) = [];

D_sim(:,1:500*20) = [];
D_sim_rain(:,1:500*20) = [];

% D_sim(:,1:750*20) = [];
% D_sim_rain(:,1:500*20) = [];

disp('Initialization OK')

