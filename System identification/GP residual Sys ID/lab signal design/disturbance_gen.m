clear all; clc;
%%
addpath('data');
load('.\data\disturbance_flow');

disturbance_flow = disturbance_flow/3 - 2;          % custom scaling
t_MPC = 10;
N = 55000;
num_ens = 10;

%% Create WW disturbance

max_d_t1_WW = 6;
min_d_t1_WW = 4;
d_t1_WW = disturbance_flow*(max_d_t1_WW-min_d_t1_WW) + min_d_t1_WW;

max_d_p_WW = 10;
min_d_p_WW = 4;
d_p_WW = disturbance_flow*(max_d_p_WW-min_d_p_WW) + min_d_p_WW;

%% Scenario generation d_t1_WW

var_t1_WW = 0.9;

% Scenario generation with randn
for i = 1:num_ens
    if i == 1
        d_t1_WW_ens(i,:) = d_t1_WW(1:t_MPC:end);
    else
        d_t1_WW_ens(i,:) = smooth(smooth(d_t1_WW(1:t_MPC:end) + (randn(size(d_t1_WW(1:t_MPC:end),2),1)*var_t1_WW)'))';
    end 
end

% upper limit calculation 
for i = 1:size(d_t1_WW_ens(1,:),2)
        d_t1_WW_UB(1,i) = max(d_t1_WW_ens(:,i));
end
% lower limit calculation 
for i = 1:size(d_t1_WW_ens(1,:),2)
        d_t1_WW_LB(1,i) = min(d_t1_WW_ens(:,i));
end
% mean calculation 
d_t1_WW_mean = mean(d_t1_WW_ens,1);

figure
for i = 1:num_ens
plot(d_t1_WW_ens(i,:))
hold on
end
hold on
jbfill([1:size(d_t1_WW_ens(1,:),2)],d_t1_WW_UB,d_t1_WW_LB,'black','none',1,0.2)
hold on
plot(d_t1_WW_mean,'black--','LineWidth',1.2)
grid on
xlim([0,1000])

for i = 1:num_ens
    d_t1_WW_ens_sim(i,:) = resample(d_t1_WW_ens(i,:),t_MPC,1);
end

%% Flow separation - t1

% load('.\generated_data\D_sim');
% 
% D_sim_rain(1,:) = D_sim(1,:) - resample(d_t1_WW(1,1:55000),4,1)*1.2;
% 
% for i = 1:220000
%     if D_sim_rain(1,i) <= 0
%         D_sim_rain(1,i) = 0;
%     end
% end
% 
% D_sim_rain(2,:) = zeros(1,220000);
% D_sim_rain(3,:) = zeros(1,220000);
% 
% save('D_sim_rain','D_sim_rain')

%% Scenario generation d_p WW

var_p_WW = 2.5;

% Scenario generation with randn
for i = 1:num_ens
    if i == 1
        d_p_WW_ens(i,:) = d_p_WW(1:t_MPC:end);
    else
        d_p_WW_ens(i,:) = smooth(smooth(d_p_WW(1:t_MPC:end) + (randn(size(d_t1_WW(1:t_MPC:end),2),1)*var_p_WW)'))';
    end
end

% upper limit calculation 
for i = 1:size(d_p_WW_ens(1,:),2)
        d_p_WW_UB(1,i) = max(d_p_WW_ens(:,i));
end
% lower limit calculation 
for i = 1:size(d_p_WW_ens(1,:),2)
        d_p_WW_LB(1,i) = min(d_p_WW_ens(:,i));
end
% mean calculation 
d_p_WW_mean = mean(d_p_WW_ens,1);

figure
for i = 1:num_ens
plot(d_p_WW_ens(i,:))
hold on
end
hold on
jbfill([1:size(d_p_WW_ens(1,:),2)],d_p_WW_UB,d_p_WW_LB,'black','none',1,0.2);
hold on
plot(d_p_WW_mean,'black--','LineWidth',1.2)
grid on
xlim([0,1000])

for i = 1:num_ens
    d_p_WW_ens_sim(i,:) = resample(d_p_WW_ens(i,:),t_MPC,1);
end

%% Flow separation - p

% d_p_temp = resample(d_p_WW_ens_sim(1,:),1,5);
% d_w_p = d_p_temp(1:5000);
% d_r_p = d(3,:) - d_w_p;
% 
% plot(d_r_p + d_w_p)
% hold on
% plot(d_w_p)

%%
d_w = [d_w_t1; zeros(1,5000); d_w_p];
d_r = [d_r_t1; zeros(1,5000); d_r_p];

save('.\generated_data\d_w','d_w')
save('.\generated_data\d_r','d_r')

%% Create rain for tank 1

a = 0.5;    % shape
b = 1.5;    % scale
for i = 1:num_ens
    rand_gen(i,:) = gamrnd(a,b,round(size(d_t1_WW,2)/t_MPC),1);
    d_t1_rain_temp(i,:) = smooth(smooth(rand_gen(i,:)));
end

M = 20;
for i = 1:size(d_t1_rain_temp(1,:),2)
    if d_t1_rain_temp(1,i) < 0.4
        for j = 1:num_ens
        d_t1_rain_temp(j,i) = 0;
        end
        if i > M
            for k = 1:M
                for j = 1:num_ens
                d_t1_rain_temp(j,i-k) = 0;
                end
            end
        end
    end
end

for i = 1:num_ens
    d_t1_rain(i,:) = smooth(d_t1_rain_temp(i,:))*2.5;
end

figure
for i = 1:num_ens
   plot(d_t1_rain(i,:))
   hold on
end

N_zero = 50;
for i = 1:num_ens
    d_t1_rain_sim(i,:) = resample(d_t1_rain(i,:),t_MPC,1);
    d_t1_rain_sim(i,1:N_zero) = 0;
end


%% Create rain for pipe

a = 0.5;    % shape
b = 1.5;    % scale
for i = 1:num_ens
    rand_gen(i,:) = gamrnd(a,b,round(size(d_t1_WW,2)/t_MPC),1);
    d_p_rain_temp(i,:) = smooth(smooth(rand_gen(i,:)));
end

M = 20;
for i = 1:size(d_p_rain_temp(1,:),2)
    if d_p_rain_temp(1,i) < 0.4
        for j = 1:num_ens
        d_p_rain_temp(j,i) = 0;
        end
        if i > M
            for k = 1:M
                for j = 1:num_ens
                d_p_rain_temp(j,i-k) = 0;
                end
            end
        end
    end
end

for i = 1:num_ens
    d_p_rain(i,:) = smooth(d_p_rain_temp(i,:))*2.5;
end

figure
for i = 1:num_ens
   plot(d_p_rain(i,:))
   hold on
end

N_zero = 50;
for i = 1:num_ens
    d_p_rain_sim(i,:) = resample(d_p_rain(i,:),t_MPC,1);
    d_p_rain_sim(i,1:N_zero) = 0;
end

%% Plot

for i = 1:num_ens
   d_t1(i,:) =  d_t1_rain_sim(i,1:N) + d_t1_WW_ens_sim(i,1:N)*1.2;
   d_p(i,:)  = d_p_rain_sim(i,1:N) + d_p_WW_ens_sim(i,1:N);
end

figure
subplot(2,1,1)
for i = 1:num_ens
    plot(d_t1(i,:))
    hold on
end

subplot(2,1,2)
for i = 1:num_ens
    plot(d_p(i,:))
    hold on
end

d_t2 = zeros(num_ens,N);

%% Save data
D_sim_ens = resample([d_t1; d_t2; d_p]',4,1)';%[d_t1; d_t2; d_p];
%save('.\generated_data\D_sim_ens','D_sim_ens')
