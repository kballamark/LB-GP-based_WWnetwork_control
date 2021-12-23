%% LevelControl.m
% """
% Level control. Uses On/Off fixed-speed pump configuration with respect 
% to water level measurements. Flag variables account for filling/emptying switching feature.
%
% Input:  tank level 
%         flag
%         Qon, Qoff
%
% Output: flow Qon/Qoff setpoints
% """

try 
    if i == 1
    % pump dynamics with [-,x,-] delay
    sys = tf(1,[1 6 1]);
    end
    % On/Off level control for tank 1
    if X_sim(1,i) >= max_t1
        input1 = u1_on * (0.8 + (1-0.8).*rand(1,1));
    elseif X_sim(1,i) <= min_t1 
        input1 = u1_off; 
    end 
    % pump1 dynamics
    input1_log = [input1_log;input1];
    input1_dyn = lsim(sys,input1_log,0:i);
    U_opt(1,i) = input1_dyn(end);
    %end
    % On/Off level control for tank 2
    if X_sim(2,i) >= max_t2 
        input2 = u2_on * (0.6 + (1-0.6).*rand(1,1));
    elseif X_sim(2,i) <= min_t2 
        input2 = u2_off;
    end 
    % pump1 dynamics
    input2_log = [input2_log;input2];
    input2_dyn = lsim(sys,input2_log,0:i);
    U_opt(2,i) = input2_dyn(end);
catch
    fprintf('Error in on/off control \n');
end

%% test