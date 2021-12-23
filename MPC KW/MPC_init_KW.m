
clear all;
clc;
%% ============================================ Control setup ======================================
% addpath('.\Lab_simulator\Simulator\lab signal design\generated_data');
% load('.\Lab_simulator\Simulator\lab signal design\generated_data\d_lab');
% addpath('.\Lab_simulator\Simulator')

%% Basic properties for simulator
Nxt = 2;                            % number of tank states
Nxp = 4;                            % number of channel states 
NP = 3 + 2;                         % number of channel parameters 
ND = 3;                             % number of disturbances

load('.\Lab_simulator\Simulator\parameters\P_pipe_min')     % load Gravity pipe parameters
load('.\Lab_simulator\Simulator\parameters\P_pipe_min_v2')     % load Gravity pipe parameters

Kt = 4.9087;
P_sim = [P_pipe_min_v2, Kt, Kt]';      % all sim parameters

%% Properties for ON/OFF controller
% Tank constraints
max_t1 = 7.9;     
min_t1 = 1.7;             % 6.7 physical maximum 
max_t2 = 6.4;%7.02;     
min_t2 = 1.7;

% Pipe constraints
h_p_max = [0.3;0.3;0.3;0.3];
h_p_min = [0.0001;0.0001;0.0001;0.0001];

u1_on = 10.5;          
u1_off = 5;
u2_on = 20;%17.5;%19.5;         
u2_off = 6;

%% MPC specs
Hp = 40;
dt_MPC = 0.5*t_resample/60;

% lam_g = 0;                                                                                % warm start - Lagrange multiplier initializer
% x_init = 0.001;  

%X_ref_design;   
t_step = 20;

dt_sim = 0.5*t_resample/60;  

%% Forecasts 
load('Lab_Deterministic_MPC_full_system_KW\D_sim.mat');
%% reference
load('Lab_Deterministic_MPC_full_system_KW\X_ref_sim.mat');
%resample(X_ref_sim,1,2);
X_ref_sim_mod = X_ref_sim;
clear X_ref_sim;
X_ref_sim(1,:) = resample(X_ref_sim_mod(1,:),1,2);
X_ref_sim(2,:) = resample(X_ref_sim_mod(2,:),1,2);

D_sim(3,:) = D_sim(3,:)*0.8+1.5;

%%
MPC_builder;




