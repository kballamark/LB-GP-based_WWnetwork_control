

U_opt = zeros(2,1);
D_sim_sim_plot = D_sim_rain(:,21);
D_sim_sim_f_plot = D_sim_rain(:,21);
          
    figure()
    subplot(3,2,1)
    dp1{1} = plot(D_sim_sim_f_plot(1,:)','red--','LineWidth',1.5);
    hold on
    plot(D_sim(1,400:20:N*20)','blue','LineWidth',1.5)
%     hold on
%     for j = 110:115:N
%         xline(j);
%     end
    leg = legend('Rain forecast','Actual WW + Rain');
    set(leg,'Interpreter','latex');
    title('Inflow $t_1$','interpreter','latex')
    xlabel('Time $[10s]$','interpreter','latex');
    ylabel('Flow $[l/m]$','interpreter','latex');
    grid on
%
     subplot(3,2,2)
     dp1{2} = plot(D_sim_sim_f_plot(3,:)','red--','LineWidth',1.5);
     hold on
     plot(D_sim(3,400:20:N*20),'blue','LineWidth',1.5)
%      hold on
%      for j = 110:115:N
%         xline(j);
%     end
    leg = legend('Rain forecast','Actual WW + Rain');
    set(leg,'Interpreter','latex');
     title('Inflow $t_2$','interpreter','latex')
     xlabel('Time $[10s]$','interpreter','latex');
     ylabel('Flow $[l/m]$','interpreter','latex');
     grid on
%   
    subplot(3,2,3)
    xpl{1} = plot(X_sim(1,:)','blue','LineWidth',3);
    hold on
    shade1 = area([1 N],[max_t1_op max_t1_op],min_t1_op);
    shade1.FaceColor = 'red';
    shade1.FaceAlpha = 0.05;  
    shade1.LineStyle = '--';  
    shade1.ShowBaseLine = 'off';
    %plot(X_ref_sim(1,1:20:end),'red','LineWidth',1.1)
    plot([0 N;0 N]',[max_t1, max_t1;min_t1 min_t1]','red--');
    title('Tank $t_1$ state','interpreter','latex')
    xlabel('Time $[10s]$','interpreter','latex');
    ylabel('Level $[dm]$','interpreter','latex');
    grid on
%     x_pred{1} = plot(X_sim(1,:)');
    subplot(3,2,4)
    xpl{2} = plot(X_sim(2,:)','blue','LineWidth',3);
    hold on
    shade2 = area([1 N],[max_t2_op max_t2_op],min_t2_op);
    shade2.FaceColor = 'red';
    shade2.FaceAlpha = 0.05;  
    shade2.LineStyle = '--';  
    shade2.ShowBaseLine = 'off';
    %plot(X_ref_sim(2,1:20:end),'red','LineWidth',1.1)
    plot([0 N;0 N]',[max_t2, max_t2;min_t2 min_t2]','red--');
    title('Tank $t_2$ state','interpreter','latex')
    xlabel('Time $[10s]$','interpreter','latex');
    ylabel('Level $[dm]$','interpreter','latex');
    grid on
%     x_pred{2} = plot(X_sim(2,:)');
%
    subplot(3,2,5)
    upl{1} = plot(U_opt(1,:)','red','LineWidth',1.5);
    title('Pump 1','interpreter','latex')
    grid on
%
    subplot(3,2,6)
    upl{2} = plot(U_opt(2,:)','red','LineWidth',1.5);
    PlotPredictions=zeros(7,N*Hp);
    title('Pump 2','interpreter','latex')
    grid on