function [output]  = simulink_onoff(h0,time)

% define persistent variables
eml.extrinsic('evalin');
persistent max_t1;
persistent min_t1;
persistent max_t2;
persistent min_t2;
persistent u1_on;
persistent u1_off;
persistent u2_on;
persistent u2_off;
persistent input1;
persistent input2;

% Sample time in minutes
dT = 1/6;             
% Sampling frequency in seconds
simulink_frequency = 2;  

% init persistent variables
if isempty(max_t1)
    max_t1 = 6.9;     
    min_t1 = 2;            
    max_t2 = 6.4;               
    min_t2 = 2;
    u1_on = 7.8;       
    u1_off = 4.5;
    u2_on = 15;   
    u2_off = 5;
    input1 = 7.8;
    input2 = 15;
    
    % get values from workspace
    max_t1 = evalin('base','max_t1');
    min_t1 = evalin('base','min_t1');
    max_t2 = evalin('base','max_t2');
    min_t2 = evalin('base','min_t2');
    u1_on = evalin('base','u1_on');
    u1_off = evalin('base','u1_off');
    u2_on = evalin('base','u2_on');
    u2_off = evalin('base','u2_off');
    input1 = evalin('base','input1');
    input2 = evalin('base','input2');
end

time = int64(round(time)); % unused in this control setup

h0 = h0/100;

tic
% Onoff Q1
if h0(1) >= max_t1
        input1 = u1_on; %* (0.8 + (1-0.8).*rand(1,1));                      % random amplitude
elseif h0(1) <= min_t1 
        input1 = u1_off; 
end 

% Onoff Q2
if h0(2) >= max_t2 
        input2 = u2_on; %* (0.6 + (1-0.6).*rand(1,1));
elseif h0(2) <= min_t2 
        input2 = u2_off;
end 
toc

output = [input1; input2];

end
