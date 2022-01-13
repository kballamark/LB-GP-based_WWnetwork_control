
dt = 1;

% Disturbances
dp1{1}.XData = (0:i)*dt;
dp1{2}.XData = (0:i)*dt;

dp1{1}.YData = D_sim_sim_f_plot(1,:);
dp1{2}.YData = D_sim_sim_f_plot(3,:);

dp1{1}.Parent.XLim = [0 i+Hp];
dpl{2}.Parent.XLim = [0 i+Hp];

% Tank states
xpl{1}.XData = (0:i)*dt;
xpl{2}.XData = (0:i)*dt;
xpl{1}.YData = X_sim(1,:);
xpl{2}.YData = X_sim(2,:);

xpl{1}.Parent.XLim = [0 i+Hp];
xpl{2}.Parent.XLim = [0 i+Hp];
hold(xpl{1}.Parent,'on')
Uncertainty = real(sqrt(full(sigma_X_opt)));
fill(xpl{1}.Parent,[i-1:(i+Hp-2) (i+Hp-2):-1:i-1],[Z_pred(1,:) + Uncertainty(1,1:Nx:end) fliplr(Z_pred(1,:)-Uncertainty(1,1:Nx:end))],'yellow','facealpha',.3,'LineStyle','none')
% plot(x_plot{1}.Parent,i:(i+Hp-1),Z_pred(1,:)+Uncertainty(1,1:6:end),'g')
% plot(x_plot{1}.Parent,i:(i+Hp-1),Z_pred(1,:)-Uncertainty(1,1:6:end),'g')
plot(xpl{1}.Parent,i-1:(i+Hp-2),Z_pred(1,:),'r','LineWidth',0.3)
hold(xpl{1}.Parent,'off')

hold(xpl{2}.Parent,'on')
fill(xpl{2}.Parent,[i-1:(i+Hp-2) (i+Hp-2):-1:i-1],[Z_pred(2,:)+Uncertainty(2,2:Nx:end) fliplr(Z_pred(2,:)-Uncertainty(2,2:Nx:end))],'yellow','facealpha',.3,'LineStyle','none')
% plot(xpl{2}.Parent,i:(i+Hp-1),Z_pred(2,:)+Uncertainty(2,2:6:end),'g')
% plot(xpl{2}.Parent,i:(i+Hp-1),Z_pred(2,:)-Uncertainty(2,2:6:end),'g')
plot(xpl{2}.Parent,i-1:(i+Hp-2),Z_pred(2,:),'r','LineWidth',0.3)
hold(xpl{2}.Parent,'off')
% xlim([0,i])

%inputs
upl{1}.XData = (0:i-1)*dt;
upl{2}.XData = (0:i-1)*dt;
upl{1}.YData = U_opt(1,:);
upl{2}.YData = U_opt(2,:);

upl{1}.Parent.XLim = [0 i+Hp];
upl{2}.Parent.XLim = [0 i+Hp];

xlim([0,i+Hp])