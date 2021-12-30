clear all;
clc;

addpath('time series')

%% Basic properties for simulator
Nxt = 2;                            % number of tank states
Nxp = 4;                            % number of channel states 
NP = 3 + 2;                         % number of channel parameters 
ND = 3;                             % number of disturbances

%% Properties - controller
% Tank constraints
max_t1 = 6.8;     
min_t1 = 2;             % 6.7 physical maximum 
max_t2 = 6.1;           %7.02;     
min_t2 = 2;

% Pipe constraints
h_p_max = [0.3;0.3;0.3;0.3];
h_p_min = [0.0001;0.0001;0.0001;0.0001];

% Pump constraints
u1_on = 7.8;%10.5;          
u1_off = 4.5;
u2_on = 15;%17.5;%19.5;         
u2_off = 5;

%% Control specs

t_resample = 20;
dt_MPC = 0.5*t_resample/60; 
t_step = 20;
dt_sim = 0.5*t_resample/60;  

%% Forecasts 
load('time series\D_sim.mat');

% modification
D_sim(1,:) = D_sim(1,:)*0.7+1;
D_sim(3,:) = D_sim(3,:)*0.8+1.5;

%% Onoff init 
input1 = u1_on;
input2 = u2_on;



