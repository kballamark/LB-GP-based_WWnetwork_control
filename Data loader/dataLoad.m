clear all; clc
%% Simulink workspace load
% """
% 1     : tank 1 level
% 2:5   : pipe levels
% 6     : NAN (tank2 inflow) 
% 7     : tank2 level
% 8     : Gravity pipe inflow (input) 
% 9     : tank2 outflow 
% 10    : tank2 area 
% 11    : real time 
% 12    : lateral inflow (disturbance)
% 13    : inflow to tank1 
% 14:17 : [pump1_ref(inflow), pump2_ref(outflow), inflow to tank1_ref, lateral inflow_ref]
% """

addpath('data');
load('data/DataSave_MPC_GP_23_01_2022_v1');
% DataSave_MPC_GP_23_01_2022
% DataSave_Onoff_25_01_2022
%load('Lab_simulator\Simulator\data\Simulation_data_WWdata_v2');
%%
labRes = ans;

% Outflow calculation from tank2 level
labRes.Data(1:end-1,6) = (2/10^6)*labRes.Data(1,10)*(labRes.Data(2:end,7) - labRes.Data(1:end-1,7)) + 1*uConv(labRes.Data(1:end-1,9),'mTos');
 
%% ================================================ Prepare data ==============================================                                                                   % ~3.5 [h] long measurement data
startData = 2;                                                                  % the first data point is corrupted
t_resample = 20;                                                                % Resample raw data (original is 20)
endData = size(labRes.Data,1);
% state
x(1,:) = labRes.Data(startData:t_resample:endData-1,1)'/100;                    % [dm]
x(2,:) = labRes.Data(startData:t_resample:endData-1,7)'/100;                    % [dm]
x(3:6,:) = medfilt1(labRes.Data(startData:t_resample:endData-1,2:2+4-1)'/100,3);% [dm]

% input
u(1,:) = uConv(labRes.Data(startData:t_resample:endData-1,8),'none');           % [dm^3/s]
u(2,:) = uConv(labRes.Data(startData:t_resample:endData-1,9),'none');           % [dm^3/s]

% Lab experiment: reference to the pumps
u_ref(1,:) = uConv(labRes.Data(startData:t_resample:endData-1,14),'none');           % [dm^3/s]
u_ref(2,:) = uConv(labRes.Data(startData:t_resample:endData-1,15),'none');           % [dm^3/s]

% disturbance
d(1,:) = uConv(labRes.Data(startData:t_resample:endData-1,13),'none');          % dt1
d(2,:) = zeros(1,length(d(1,:)));                                               % dt2
d(3,:) = uConv(labRes.Data(startData:t_resample:endData-1,12),'none');          % wp

y = uConv(hampel(smooth(labRes.Data(startData:t_resample:endData,6)),2),'sTom');

% tank constant
conv_mm2Todm2 = 10^-4;
Kt = labRes.Data(1,10)*conv_mm2Todm2;

%plot(y)

% KPIs
KPI_u = labRes.Data(startData:t_resample:endData-1,22)'; 
KPI_s = labRes.Data(startData:t_resample:endData-1,23)'; 
KPI_o = labRes.Data(startData:t_resample:endData-1,24)'; 
KPI_sigma = labRes.Data(startData:t_resample:endData-1,25)'; 

%% 
% Input constraints                 % UNIT:[l/min]  
u1_on  = 6.5;                       % 6.5                                          
u1_off = 3.5;                       % 3.5  
u2_on  = 14;                        % 14  
u2_off = 5.4;                       % 5.4       
% Tank constraints                  % UNIT:[dm] 
max_t1 = 6.8;                       % 6.9    
min_t1 = 4.2 + 0.15;             
max_t2 = 5.8;%5.95;     
min_t2 = 4.3 + 0.15 ;
% Tank safety region
max_t1_op = 5.6 + 0.15;                    % UNIT:[dm] 
min_t1_op = 4.4 + 0.15;
max_t2_op = 5.2;
min_t2_op = 4.5 + 0.15;

plotEnable = 1;
if plotEnable == 1
figure
ax(1) = subplot(3,2,1);
plot(d(1,:)','black','LineWidth',0.5)
ylabel('Flow','interpreter','latex');
xlabel('Time','interpreter','latex');
title('$q_{t_1}$','interpreter','latex')
grid on
xlim([0, length(d)]);

ax(2) = subplot(3,2,2);
plot(d(3,:)','black','LineWidth',0.5)
ylabel('Flow','interpreter','latex');
xlabel('Time','interpreter','latex');
title('$q_p$','interpreter','latex')
grid on
xlim([0, length(d)]);

ax(3) = subplot(3,2,3);
plot(x(1,:)','red','LineWidth',0.5)
hold on
yline(min_t1,'black-','Min');
hold on
yline(max_t1,'black-','Max');
hold on
yline(min_t1_op,'blue--','LineWidth',2);
hold on
yline(max_t1_op,'blue--','LineWidth',2);

ylabel('Level','interpreter','latex');
xlabel('Time','interpreter','latex');
title('$h_{t_1}$','interpreter','latex')
grid on
xlim([0, length(d)]);

ax(4) = subplot(3,2,4);
plot(x(2,:)','red','LineWidth',0.5)
hold on
yline(min_t2,'black-','Min');
hold on
yline(max_t2,'black-','Max');
hold on
yline(min_t2_op,'blue--','LineWidth',2);
hold on
yline(max_t2_op,'blue--','LineWidth',2);
ylabel('Level','interpreter','latex');
xlabel('Time','interpreter','latex');
title('$h_{t_2}$','interpreter','latex')
grid on
xlim([0, length(d)]);

ax(5) = subplot(3,2,5);
plot(u(1,:)','blue','LineWidth',0.5)
hold on
plot(u_ref(1,:)','red','LineWidth',0.5)
hold on
yline(u1_off,'red--','Min','LineWidth',1.5);
hold on
yline(u1_on,'red--','Max','LineWidth',1.5);
ylabel('Flow','interpreter','latex');
xlabel('Time','interpreter','latex');
title('$Q_{t_1}$','interpreter','latex')
grid on
xlim([0, length(d)]);

ax(6) = subplot(3,2,6);
plot((u(2,:))','blue','LineWidth',0.5)
hold on
plot((u_ref(2,:))','red','LineWidth',0.5)
hold on
yline(u2_off,'red--','Min','LineWidth',1.5);
hold on
yline(u2_on,'red--','Max','LineWidth',1.5);
ylabel('Flow','interpreter','latex');
xlabel('Time','interpreter','latex');
title('$Q_{t_1}$','interpreter','latex')
grid on
xlim([0, length(d)]);

linkaxes(ax,'x');

figure
plot(x(3:6,:)','LineWidth',0.5)
ylabel('Water level','interpreter','latex');
xlabel('Time','interpreter','latex');
title('Pipe states','interpreter','latex')

figure
ax(1) = subplot(4,1,1);
plot(KPI_u,'LineWidth',0.5)

ax(2) = subplot(4,1,2);
plot(KPI_s,'LineWidth',0.5)

ax(3) = subplot(4,1,3);
plot(KPI_o,'LineWidth',0.5)

ax(4) = subplot(4,1,4);
plot(KPI_sigma,'LineWidth',0.5)
linkaxes(ax,'x');

end

%% Save dataSets

 x_o_GP(1,:) = ((labRes.Data(startData:t_resample:endData-1,18)'/100))*(Kt/(1/6))-61.28;
 x_o_GP(2,:) = ((labRes.Data(startData:t_resample:endData-1,19)'/100))*(Kt/(1/6))-75.3;
% 
%  x_onoff = x;
%  u_onoff = u;
% % d_onoff = d;
%  u_ref_onoff = u_ref;
% % 
%  save('x_onoff','x_onoff')
%  save('u_onoff','u_onoff')
% % save('d_onoff','d_onoff')
%  save('u_ref_onoff','u_ref_onoff')
% save('x_o_onoff','x_o_onoff')

% 
%x = x(:,1:2500);
%u = u(:,1:2500);
%d = d(:,1:2500);
% 
% save('save_sys_ID/x_long_v1','x')
% save('save_sys_ID/u_long_v1','u')
% save('save_sys_ID/d_long_v1','d')

% x = x(:,1:2800);
 %u = u(:,1:2800);
% d = d(:,1:2800);
% 
% save('save_sys_ID/x_part2','x')
 %save('save_sys_ID/u_ref_part2','u')
% save('save_sys_ID/d_part2','d')


