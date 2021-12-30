clear all;
clc;

addpath('control')
addpath('time series')

%% Basic properties for simulator
Nxt = 2;                            % number of tank states
Nxp = 4;                            % number of channel states 
NP = 3 + 2;                         % number of channel parameters 
ND = 3;                             % number of disturbances

load('.\parameters\P_pipe_min_v2')     % load Gravity pipe parameters
load('.\parameters\Kt')                 % load Tank parameters

P_sim = [P_pipe_min_v2, Kt, Kt]';      % all sim parameters

%% Properties - controller
% Tank constraints
max_t1 = 6.9;     
min_t1 = 2;             % 6.7 physical maximum 
max_t2 = 6.4;           %7.02;     
min_t2 = 2;

% Pipe constraints
h_p_max = [0.3;0.3;0.3;0.3];
h_p_min = [0.0001;0.0001;0.0001;0.0001];

% Pump constraints
u1_on = 7.8;%10.5;          
u1_off = 4.5;
u2_on = 15;%17.5;%19.5;         
u2_off = 5;

du1 = u1_on - u1_off;
du2 = u2_on - u2_off;

%% MPC specs
Hp = 60;
t_resample = 20;
dt_MPC = 0.5*t_resample/60;

lam_g = 1;                     % warm start - Lagrange multiplier initializer
x_init = 0.001;  
 
t_step = 20;
dt_sim = 0.5*t_resample/60;  

%% Forecasts 
load('time series\D_sim.mat');

% modification
D_sim(1,:) = D_sim(1,:)*0.7+1;
D_sim(3,:) = D_sim(3,:)*0.8+1.5;
%% reference
load('time series\X_ref_sim.mat');

X_ref_sim(1,:) = 4;
X_ref_sim(2,:) = 4;

%%
MPC_builder;

