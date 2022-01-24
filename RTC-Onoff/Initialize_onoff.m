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
max_t1 = 5.75;           % 6.7 physical maximum    
min_t1 = 4.55;%3.8;             % 6.7 physical maximum 
max_t2 = 5.2;           %6.1 max?      
min_t2 = 4.65;%4.3;

% Pipe constraints
h_p_max = [0.3;0.3;0.3;0.3];
h_p_min = [0.0001;0.0001;0.0001;0.0001];

% Pump constraints
u1_on = 6.5;         
u1_off = 3.5;
u2_on = 14;         
u2_off = 5.4;

%% Control specs

t_resample = 20;
dt_MPC = 0.5*t_resample/60; 
t_step = 20;
dt_sim = 0.5*t_resample/60;  

%% Forecasts 
load('time series\D_sim.mat');

D_sim(:,1:115*20) = [];

D_sim(:,1:200*20) = [];

% modification
% D_sim(1,:) = D_sim(1,:)*0.7+1;
% D_sim(3,:) = D_sim(3,:)*0.8+1.5;

%% Onoff init 
input1 = u1_on;
input2 = u2_on;

%% cut beginning of experiment
%D_sim(:,1:2500*20) = [];

