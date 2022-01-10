clear pred_N
clear x_hat
clear x0
clear pred_N_save
clear conf_N_save
clear ress_ci_np_full
clear ress_ci_np

%% Np long prediction

num_x = [1,2,1,2];                                                              % number of state regressor in residuals
N_pred = 4;
k = 1;

start_n = 6940;%7900;
stop_n = 7090;%8600;
   
for n = start_n:stop_n

    x0 = z(1:Nx,n);
    x_hat = zeros(Nx,N_pred);
    x_hat(:,1) = x0;
    ress_ci_np = zeros(1,2);

    for i = 1:N_pred
        %pred_N = zeros(Nx,1);

        for j = 1:Nx
           %[pred_N,~,ress_ci_np] = predict(gps{j}, [C{j}(1:num_x(j),1:Nx)*x_hat(:,i); C{j}(num_x(j)+1:end,:)*z(:,n+i-1)]');
           [pred_N,ress_ci_np] = GP_predict(i,j,n,gps,C,x_hat,z,num_x,Nx);
           x_hat(j,i+1)= pred_N;
           ress_ci_np_full{j}(i,:) = ress_ci_np;
        end
        
        if sum(isnan(pred_N)) > 0
            return
        end

        %x_hat(:,i+1)= pred_N ;
    end

%     figure
%     subplot(2,1,1)
%     plot(r)
%     subplot(2,1,2)
%     plot(z(j,n:n+N_pred))
%     hold on
%     plot(x_hat(j,:))

    pred_N_save(:,k) = x_hat(:,end);
    for l = 1:Nx
    conf_N_save{l}(k,:) = ress_ci_np_full{l}(end,:);
    end
    k = k + 1;
    k

end
%%
for select = 1:Nx
figure
plot(z(select,start_n + N_pred : stop_n+N_pred))
hold on
plot((pred_N_save(select,:)))
hold on
ciplot(conf_N_save{select}(:,1) ,conf_N_save{2}(:,2)) 
end



