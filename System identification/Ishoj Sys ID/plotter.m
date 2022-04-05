%% 1-step predictions

lw = 1.2;
oneStepPredred = 1;
if oneStepPredred == 1
for i = 2%1:Nx
num_gp = i;                                                                     % gp selection
gp1 = gps{num_gp};
np = size(z,2)-n-1;                                                             % number of predictions

figure
ax(1) = subplot(2,1,1);
h1 = gca;
yyaxis right
stairs(z(end,offset:offset+n),'Color',[0.9290 0.6940 0.1250],'LineWidth',lw);
%bar(z(end,offset:offset+n),'LineWidth',lw);
set(h1, 'YDir', 'reverse')
ylabel('Intensity [$\mu m / s$]','interpreter','latex')
ylim([0,14])
%
respred1 = resubPredict(gp1);
yyaxis left
plot(y(num_gp,offset:offset+n),'blue');
hold on 
plot(respred1,'red')
title('Training','interpreter','latex')
leg = legend('Data','Model','Rain');
set(leg,'Interpreter','latex');
ylabel('Level [m]','interpreter','latex')
grid on
set(ax(1), 'XTick', 0:288:n)
xticklabels({'0','1','2','3','4','5','6','7','8','9','10','11','12','13','14','15','16','17','18'})
xlim([0,n])
% 
ax(2) = subplot(2,1,2);
h2 = gca;
yyaxis right
stairs(z(end,n:n+np),'Color',[0.9290 0.6940 0.1250],'LineWidth',lw);
set(h2, 'YDir', 'reverse')
ylabel('Intensity [$\mu m / s$]','interpreter','latex')

[respred1,~,ress_ci] = predict(gp1, (C{i}*z(:,n:n+np))');
ress_ci(isnan(ress_ci)) = 0;

if i == 1
    ress_ci = 1.*ress_ci;
elseif i == 5
    ress_ci = 1.*ress_ci;
end

yyaxis left
plot(y(num_gp,n:(n+np)),'blue');
hold on 
plot(respred1,'red')
hold on
ciplot(ress_ci(1:end,1),ress_ci(1:end,2)) 
title('Prediction','interpreter','latex')
leg = legend('Data','Model','Confidence','Rain');
set(leg,'Interpreter','latex');
xlabel('Time [days]','interpreter','latex')
ylabel('Level [m]','interpreter','latex')
grid on
set(ax(2), 'XTick', 0:288:(n+np)-n)
%xticklabels({'19','20','21','22','23','24','25',...
%    '26','27','28','29','30','31','32','33','34','35','36','37','38','39','40','41','42','43'})
xticklabels({'12','13','14','15','16','17','18',...
   '19','20','21','22','23','24','25','26','27','28','29','30','31'})
xlim([0,(n+np)-n])

%sgtitle('Manhole 4')
end
end

%%




