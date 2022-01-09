%% Length scale relevances
% Relevance of the regressors show the effect of the different inputs
% on the output residuals 
for i = 1:Nx 
    weights{i} = exp(-gps{i}.KernelInformation.KernelParameters(1:end-1));      % Predictor weights
    weights{i} = weights{i}/sum(weights{i});                                    % normalized predictor weights
end

figure
for i = 1:Nx
    subplot(2,2,i)
    %plot(weights{i},'ro','LineWidth',2)
    bar(weights{i})
    ylim([0,1])
    ylabel('Relevance')
    xlabel('Num. of regressor')
    grid on
    title(['Predictor relevance for y',num2str(i)],'interpreter','latex')
end

%% 1-step predictions
oneStepPredred = 1;
if oneStepPredred == 1
for i = 1:Nx
num_gp = i;                                                                     % gp selection
gp1 = gps{num_gp};
np = size(x,2)-n-1;                                                             % number of predictions

figure
subplot(2,1,1)
respred1 = resubPredict(gp1);
plot(y(num_gp,offset:offset+n),'blue.');
hold on 
plot(respred1,'red','Linewidth',1.2)
title('1 step prediction - training data','interpreter','latex')
leg = legend('Data','Model');
set(leg,'Interpreter','latex');
ylabel('Level [$dm$]','interpreter','latex')
grid on
% 
subplot(2,1,2)
[respred1,~,ress_ci] = predict(gp1, (C{i}*z(:,n:n+np))');
plot(y(num_gp,n:(n+np)),'.');
hold on 
plot(respred1)
hold on
ciplot(ress_ci(:,1),ress_ci(:,2)) 
title('1 step prediction - validation data','interpreter','latex')
leg = legend('Data','Model');
set(leg,'Interpreter','latex');
xlabel('Time [10 s]','interpreter','latex')
ylabel('Level [$dm$]','interpreter','latex')
grid on
end
end

%% Np long prediction
NstepPred = 1;
if NstepPred == 1
x0 = x(:,n);
x_hat = zeros(Nx,np);
x_hat(:,1) = x0;

for i = 1:np
    ress = zeros(Nx,1);

    for j = 1:Nx
       [ress(j),~,ress_ci_np(j,:)] = predict(gps{j}, [C{j}(1:num_x(j),1:Nx)*x_hat(:,i); C{j}(num_x(j)+1:end,:)*z(:,n+i-1)]');
    end
    if sum(isnan(ress)) > 0
        return
    end
    %x_hat(:,i+1)= [At*x_hat(1:Nxt,i) + Bt*u(1:Nxt,n+i-1) + Et*d(1:Nxt,n+i-1); x_hat(3,i); x_hat(4,i); x_hat(5,i); x_hat(6,i)] + ress;
    x_hat(:,i+1)= A*x_hat(:,i) + B*u(:,n+i-1) + E*d(:,n+i-1) + ress + [0;0;c3;c4];
end
end
%% Plot NP long prediction 
if NstepPred == 1
figure                                                                          % tank states
for i = 1:Nxt
subplot(Nxt,1,i)
plot(x(i,n:(n+np)),'.-');
hold on
plot(x_hat(i,:))
title(['Tank',' - ','x', num2str(i)],'interpreter','latex')
leg = legend('Data','Model');
set(leg,'Interpreter','latex');
ylabel('Level [$dm$]','interpreter','latex')
end
xlabel('Time [10s]','interpreter','latex');

%%
figure                                                                          % pipe states
for i = Nxt+1:Nxt+Nxp
subplot(Nxp,1,i-Nxt)
plot(x(i,n:(n+np)),'.-');
hold on
plot(x_hat(i,:))
title(['Pipe',' - ','x', num2str(i)],'interpreter','latex')
leg = legend('Data','Model');
set(leg,'Interpreter','latex');
ylabel('Level [$dm$]','interpreter','latex')
end
xlabel('Time [10s]','interpreter','latex');
end