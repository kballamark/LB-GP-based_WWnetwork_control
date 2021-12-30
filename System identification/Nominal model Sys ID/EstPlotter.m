%% Initial system comparison
plotEnbaler = 1;
if plotEnbaler == 1
    figure
    ax(1) = subplot(2,1,1);
    plot(output(:,1),'b','LineWidth',0.5)
    hold on
    plot(y_init.OutputData(:,1),'r','LineWidth',0.5)
    ylabel(['$x3$ [$dm$]'],'interpreter','latex');
    leg = legend('Data','Model','Location','NorthEast');
    grid on
    set(leg, 'Interpreter', 'latex');

    ax(2) = subplot(2,1,2);
    plot(output(:,2),'b','LineWidth',0.5)
    hold on
    plot(y_init.OutputData(:,2),'r','LineWidth',0.5)
    ylabel(['$x4$ [$dm$]'],'interpreter','latex');
    leg = legend('Data','Model','Location','NorthEast');
    grid on
    set(leg, 'Interpreter', 'latex');
end

%% Estimated system comparison
plotEnbaler = 1;
if plotEnbaler == 1
    figure
    ax(1) = subplot(2,1,1); 
    plot(output(:,1),'b','LineWidth',0.5)
    hold on
    plot(y_final.OutputData(:,1),'r','LineWidth',0.5)
    ylabel(['$x3$ [$dm$]'],'interpreter','latex');
    leg = legend('Data','Model','Location','NorthEast');
    grid on
    set(leg, 'Interpreter', 'latex');
    
    ax(2) = subplot(2,1,2);
    plot(output(:,2),'b','LineWidth',0.5)
    hold on
    plot(y_final.OutputData(:,2),'r','LineWidth',0.5)
    ylabel(['$x4$ [$dm$]'],'interpreter','latex');
    leg = legend('Data','Model','Location','NorthEast');
    grid on
    set(leg, 'Interpreter', 'latex');
    linkaxes(ax,'x')
end
