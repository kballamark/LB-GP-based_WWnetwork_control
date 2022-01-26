clear all; clc

%% Load variables

load('KPI_u')
load('KPI_s')
load('KPI_o')
load('KPI_sigma')

load('d_r_full')
load('x_o_GP','x_o_GP')

%%
startPlot = 50;
endPlot = 2200;%1600;

% forecast
d_r(:,1:115) = [];
d_r(:,1:200) = [];

%%

figure
ax(1) = subplot(3,1,1);
plot(KPI_u(startPlot:endPlot),'LineWidth',1,'Color',[0 0.2470 0.7410])
ylabel('$\textrm{KPI}_{\Delta u}$','interpreter','latex');
title('(a) Pump flow smoothness KPI','interpreter','latex')
grid on
ylim([0,0.7])
xlim([startPlot, length(KPI_u(startPlot:endPlot))]);
xticks(103:115:length(KPI_u(startPlot:endPlot)))
% leg = legend('Inflow');
% set(leg,'Interpreter','latex');
set(gca,'xticklabel',[])

ax(2) = subplot(3,1,2);
h1 = gca;
yyaxis left
%
a = [1002-startPlot 1017-startPlot 1017-startPlot 1002-startPlot];
b = [0 0 1.8 1.8];
patch(a,b,'black','FaceAlpha',.2,'LineStyle',':','HandleVisibility','off')
hold on
a = [1727-startPlot 1739-startPlot 1739-startPlot 1727-startPlot];
b = [0 0 1.8 1.8];
patch(a,b,'black','FaceAlpha',.2,'LineStyle',':','HandleVisibility','off')
hold on
a = [1811-startPlot 1825-startPlot 1825-startPlot 1811-startPlot];
b = [0 0 1.8 1.8];
patch(a,b,'black','FaceAlpha',.2,'LineStyle',':','HandleVisibility','off')
hold on
a = [1855-startPlot 1862-startPlot 1862-startPlot 1855-startPlot];
b = [0 0 1.8 1.8];
patch(a,b,'black','FaceAlpha',.2,'LineStyle',':','HandleVisibility','off')
hold on
a = [2078-startPlot 2092-startPlot 2092-startPlot 2078-startPlot];
b = [0 0 1.8 1.8];
patch(a,b,'black','FaceAlpha',.2,'LineStyle',':')
hold on
%
plot(KPI_s(startPlot:endPlot),'LineWidth',1,'Color',[0 0.2470 0.7410])
ylabel('$\textrm{KPI}_{\xi}$','interpreter','latex');
ylim([0,1.8])
yyaxis right
plot(KPI_o(startPlot:endPlot),'red','LineWidth',1)
% temp = sum(x_o_GP,1);
% plot(temp(startPlot:endPlot)*0.05)
ylim([0,1])
ylabel('$\textrm{KPI}_{\epsilon}$','interpreter','latex');
title('(b) Overflow and safety violation KPI','interpreter','latex')
grid on
% ylim([4,11])
xlim([startPlot, length(KPI_u(startPlot:endPlot))]);
xticks(103:115:length(KPI_u(startPlot:endPlot)))
 leg = legend('Overflow','Safety KPI','Overflow KPI');
 set(leg,'Interpreter','latex');
h1.YAxis(1).Color = [0 0.2470 0.7410];
h1.YAxis(2).Color = [1 0 0];
set(gca,'xticklabel',[])


ax(3) = subplot(3,1,3);
yyaxis left
plot(KPI_sigma(startPlot:endPlot),'LineWidth',1,'Color',[0 0.2470 0.7410])
ylabel('$\textrm{KPI}_{\Sigma}$','interpreter','latex');
ylim([0,0.05])
h2 = gca;
yyaxis right
bar(d_r(1,startPlot+5:endPlot),'FaceColor',[0.9290 0.6940 0.1250])
ylabel('Flow ($\frac{\textrm{dm}^3}{\textrm{min}}$)','interpreter','latex');
set(h2, 'YDir', 'reverse')
ylim([0,5])
title('(c) Uncertainty KPI','interpreter','latex')
grid on
xlim([startPlot, length(KPI_u(startPlot:endPlot))]);
xticks(103:115:length(KPI_u(startPlot:endPlot)))
h2.YAxis(1).Color = [0 0.2470 0.7410];
h2.YAxis(2).Color = [0.9290 0.6940 0.1250];
leg = legend('Uncertainty KPI','Rain forecast');
set(leg,'Interpreter','latex');
xlabel('Time (10s)','interpreter','latex');

linkaxes(ax,'x');