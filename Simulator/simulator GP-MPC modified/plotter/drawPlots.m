
dt = 1;

% Tank states
x_plot{1}.XData=(0:i)*dt;
xpl{2}.XData=(0:i)*dt;
x_plot{1}.YData=X_sim(1,:);
xpl{2}.YData=X_sim(2,:);

x_plot{1}.Parent.XLim=[0 i+Hp];
xpl{2}.Parent.XLim=[0 i+Hp];

x_pred{1}.XData=PlotPredictions(1,1:Hp*i);
x_pred{2}.XData=PlotPredictions(1,1:Hp*i);
x_pred{1}.YData=PlotPredictions(2,1:Hp*i);
x_pred{2}.YData=PlotPredictions(3,1:Hp*i);




hold(x_plot{1}.Parent,'on')
% plot(x_plot{1}.Parent,i-1:(i+Hp-2),Z_pred(1,:),'r')
% Uncertainty=sqrt(full(sigma_X_opt));
% fill(x_plot{1}.Parent,[i-1:(i+Hp-2) (i+Hp-2):-1:i-1],[Z_pred(1,:)+Uncertainty(1,1:6:end) fliplr(Z_pred(1,:)-Uncertainty(1,1:6:end))],'g')
%PlotPredictions(:,(Hp*(i-1)+1):(Hp*i))=[i-1:(i+Hp-2);Z_pred(1:2,:)];
for qq=intersect(i-Hp:i,1:N)
    plot(x_plot{1}.Parent,PlotPredictions(1,(Hp*(qq-1)+1):(Hp*qq)),PlotPredictions(2,(Hp*(qq-1)+1):(Hp*qq)),'--r');
end


hold(x_plot{1}.Parent,'off')

hold(xpl{2}.Parent,'on')
% fill(xpl{2}.Parent,[i-1:(i+Hp-2) (i+Hp-2):-1:i-1],[Z_pred(2,:)+Uncertainty(2,2:6:end) fliplr(Z_pred(2,:)-Uncertainty(2,2:6:end))],'g')
% plot(xpl{2}.Parent,i-1:(i+Hp-2),Z_pred(2,:))
for qq=intersect(i-Hp:i,1:N)
    plot(xpl{2}.Parent,PlotPredictions(1,(Hp*(qq-1)+1):(Hp*qq)),PlotPredictions(3,(Hp*(qq-1)+1):(Hp*qq)),'--r');
end
hold(xpl{2}.Parent,'off')
% xlim([0,i])
%inputs
upl{1}.XData=(0:i-1)*dt;
upl{2}.XData=(0:i-1)*dt;
upl{1}.YData=U_opt(1,:);
upl{2}.YData=U_opt(2,:);

upl{1}.Parent.XLim=[0 i+Hp];
upl{2}.Parent.XLim=[0 i+Hp];

xlim([0,i+Hp])



%% eps_pl
eps_pl{1}.XData=(0:i)*dt;
eps_pl{2}.XData=(0:i)*dt;
eps_pl{1}.YData=max(X_sim(1,:)-max_t1,0);
eps_pl{2}.YData=min(X_sim(1,:)-min_t1,0);


hold(eps_pl{1}.Parent,'on')
for qq=intersect(i-Hp:i,1:N)
    plot(eps_pl{1}.Parent,PlotPredictions(1,(Hp*(qq-1)+2):(Hp*qq)),PlotPredictions(4,(Hp*(qq-1)+2):(Hp*qq)),'--g');
    plot(eps_pl{1}.Parent,PlotPredictions(1,(Hp*(qq-1)+2):(Hp*qq)),-PlotPredictions(6,(Hp*(qq-1)+2):(Hp*qq)),'--r');
end
hold(eps_pl{1}.Parent,'off')

eps_pl{3}.XData=(0:i)*dt;
eps_pl{4}.XData=(0:i)*dt;
eps_pl{3}.YData=max(X_sim(2,:)-max_t2,0);
eps_pl{4}.YData=min(X_sim(2,:)-min_t2,0);
hold(eps_pl{3}.Parent,'on')
for qq=intersect(i-Hp:i,1:N)
    plot(eps_pl{3}.Parent,PlotPredictions(1,(Hp*(qq-1)+2):(Hp*qq)),PlotPredictions(5,(Hp*(qq-1)+2):(Hp*qq)),'--g');
    plot(eps_pl{3}.Parent,PlotPredictions(1,(Hp*(qq-1)+2):(Hp*qq)),-PlotPredictions(7,(Hp*(qq-1)+2):(Hp*qq)),'--r');
end
hold(eps_pl{3}.Parent,'off')

eps_pl{1}.Parent.XLim=[0 i+Hp];
eps_pl{3}.Parent.XLim=[0 i+Hp];
