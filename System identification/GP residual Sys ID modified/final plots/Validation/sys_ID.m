clear all; clc
%% Load data
load('gps')
load('C')
load('z')
load('y')
load('d_r_full')

load('residual_save')
load('conf_N_save_resOnly')

n = 2800;
np = 1800%size(z,2)-n-1;   

%%



%%

% figure
% for i = 1:Nx
% num_gp = i;
%                                                           % number of predictions
% % 
% subplot(3,1,i)
% [respred1,~,ress_ci] = predict(gps{i}, (C{i}*z(:,n:n+np))');
% plot(y(num_gp,n:(n+np)),'blue.');
% hold on 
% plot(respred1,'red','LineWidth',1.2)
% hold on
% ciplot(ress_ci(:,1),ress_ci(:,2)) 
% title('1 step prediction - validation data','interpreter','latex')
% leg = legend('Data','Model','Confidence interval');
% set(leg,'Interpreter','latex');
% xlabel('Time [10 s]','interpreter','latex')
% ylabel('Level [$dm$]','interpreter','latex')
% grid on
% xlim([1,np])
% end


%%

v = 87:115:np;

figure

ax(1) = subplot(3,1,1);
[respred,~,ress_ci] = predict(gps{1}, (C{1}*z(:,n:n+np))');
ciplot(ress_ci(:,1),ress_ci(:,2)) 
hold on
plot(y(1,n:(n+np)),'.','Color',[0 0.2470 0.7410],'MarkerSize',4);
hold on 
plot(respred,'Color',[0.9500 0.1250 0.0980],'LineWidth',1.7)
% hold on
% plot([zeros(1,20) ,residual_save(1,:)])
%plot(d_r(1,n:(n+np))*0.1)
title('Residual ($y_1$)','interpreter','latex')
leg = legend('Confidence interval','Data','GP model');
set(leg,'Interpreter','latex');
ylabel('Level [dm]','interpreter','latex')
grid on
xlim([1,np])
ylim([0.1,0.3])
xticks(87:115:np)

ax(2) = subplot(3,1,2);
[respred,~,ress_ci] = predict(gps{2}, (C{2}*z(:,n:n+np))');
ciplot(ress_ci(:,1),ress_ci(:,2)) 
hold on
plot(y(2,n:(n+np)),'.','Color',[0 0.2470 0.7410],'MarkerSize',4);
hold on 
plot(respred,'Color',[0.9500 0.1250 0.0980],'LineWidth',1.7)
% hold on
% plot([zeros(1,20) ,residual_save(2,:)])
title('Residual ($y_2$)','interpreter','latex')
leg = legend('Confidence interval','Data','GP model');
set(leg,'Interpreter','latex');
ylabel('Level [dm]','interpreter','latex')
grid on
xlim([1,np])
ylim([0.25,0.6])
xticks(87:115:np)

ax(3) = subplot(3,1,3);
[respred,~,ress_ci] = predict(gps{3}, (C{3}*z(:,n:n+np))');
ciplot(ress_ci(:,1),ress_ci(:,2)) 
hold on
plot(y(3,n:(n+np)),'.','Color',[0 0.2470 0.7410],'MarkerSize',4);
hold on 
plot(respred,'Color',[0.9500 0.1250 0.0980],'LineWidth',1.7)
% hold on
% plot([zeros(1,20) ,residual_save(3,:)])
title('Residual ($y_3$)','interpreter','latex')
leg = legend('Confidence interval','Data','GP model');
set(leg,'Interpreter','latex');
xlabel('Time [10 s]','interpreter','latex')
ylabel('Level [dm]','interpreter','latex')
grid on
xlim([1,np])
ylim([0.06,0.125])
xticks(87:115:np)

linkaxes(ax,'x')