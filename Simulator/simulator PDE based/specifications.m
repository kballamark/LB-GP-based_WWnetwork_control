%% control_specs.m
% """
% Specifies all the control and model specs
%
% ControlType : 1 - On / off level control 
%               2 - NMPC with PDE model
%               3 - NMPC with GP model
%               4 - NMPC with reduced GP model
% """

addpath('.\control')

%% Basic properties for simulator
Nxt = 2;                            % number of tank states
Nxp = 4;                            % number of channel states 
Nx = Nxt + Nxp;                     % all states
Nu = 2;                             % number of inputs
NP = 3 + 2;                         % number of channel parameters 
ND = 3;                             % number of disturbances

load('parameters\P_pipe_min')       % load Gravity pipe parameters
load('parameters\P_pipe_min_v2')    % load Gravity pipe parameters
load('parameters\Kt')               % load tank parameters
t_resample = 20;                    % Resample raw data - conversion between simulator/MPC time steps
if controlType == 1
    %dataLoad;                      % load data from experiment
end
P_sim = [P_pipe_min_v2, Kt, Kt]';   % all sim parameters

%% input constraints

if controlType == 1
    input1 = 0;
    input2 = 0;
    u1_on = 10.5;      
    u1_off = 5;
    u2_on = 16;     
    u2_off = 6;
elseif controlType == 2 
    u1_on = 7.8;%8.3;                           
    u1_off = 4.5;                         
    u2_on = 15;%16;%19.5; %10.5;                        
    u2_off = 5;                         
end

du1 = u1_on - u1_off;
du2 = u2_on - u2_off;

%% state constraints 
% Tank constraints
max_t1 = 7;       
min_t1 = 1.7;%1.8;             
max_t2 = 6.5;     
min_t2 = 1.7;%1.8;

% Pipe constraints
if controlType == 2
    h_p_max = [0.3;0.3;0.3;0.3];
    h_p_min = [0.0001;0.0001;0.0001;0.0001];
end

%% MPC specs
Hp = 60;                
dt_original = 0.5;
data_timeUnit = 60;
dt_MPC = dt_original*t_resample/data_timeUnit;

%% Test X_ref
load('X_ref_sim.mat');
%resample(X_ref_sim,1,2);
X_ref_sim_mod = X_ref_sim;
clear X_ref_sim;
X_ref_sim(1,:) = resample(X_ref_sim_mod(1,:),1,2);
X_ref_sim(2,:) = resample(X_ref_sim_mod(2,:),1,2);

X_ref_sim(1,1:8440) = 3;
X_ref_sim(2,1:8440) = 3;

