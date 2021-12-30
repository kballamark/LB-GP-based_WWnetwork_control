distance_pred = repelem(Z_pred,1,M/Hp) - Z_train_subset;
for j = [1,2,5,6,7]
    distance_pred_reshaped{j} = reshape(distance_pred(j,:),[M/Hp,Hp]);
end
k = 1;
for j = [1,2,5,6,7]
    dist_pred_mean(k,i) = mean(mean(abs(distance_pred_reshaped{j})));
    k = k + 1;
end

%% Maximum likelihood estimation along the horizon

beta_rain(:,i) =  mle(D_sim_sim_f(1,:));


% tic
% figure
% for i = 1:2000
% plot([0+i:19+i],abs(D_sim_rain(1,(i)*(20)-19:20:(i-1)*20 + (Hp)*20-19) + randn(1,Hp)*0.5))
% hold on
% beta_rain(:,i) =  mle(abs(D_sim_rain(1,(i)*(20)-19:20:(i-1)*20 + (Hp)*20-19) + randn(1,Hp)*0.5));
% end
% toc
% %%
% 
% figure
% plot(beta_rain(2,:))
% 
% %%
% figure
% plot(D_sim_rain(1,:))
% hold on
% plot( abs(movmean(D_sim_rain(1,1:100000),1000)))  

%%
%figure
%scatter3(ones(1114,1)*10,beta_rain(2,:),KPI_eps(1:end-1))