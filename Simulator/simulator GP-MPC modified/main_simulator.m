clearvars, clc, clear path

N = 5000;%2600;                                                                          % length of simulation (dependent on the length of disturbance data)

%% ============================================ Control setup ======================================
specifications;
%dataLoad;                                                                               % Load when comparing lab results

%% ===================================  Build dynamics & optimization  =============================
simulator_builder;                                                                       % Build simulator dynamics in Casadi
MPC_builder_GP_reduced;                                                                  % Build MPC in Casadi

%% ==========================================  Real-time plotting  ================================
PlotType = 2;
if PlotType == 2
    realTimePlotter;
end

%% ==============================================  Simulate  ======================================
disp('Simulator running')

period = 115;
t = 1:2*N;
offset = 13;
Time = mod(t-offset,period)./period;

% to update the training set
% load('training_set tests\z_retrain');
% load('training_set tests\y_retrain');
% GP.z_train = z_retrain;
% GP.y_train = y_retrain;

% quick fix: 
GP.y_train = [GP.y_train, GP.y_train(:,end)];

% GP.z_train(:,1:2:end) = [];
% GP.y_train(:,1:2:end) = [];
%
% GP.z_train(:,1:2:end) = [];
% GP.y_train(:,1:2:end) = [];

for i = t_init:1:N  
    % Get forecast
    %[D_sim_sim, D_sim_sim_f] = forecast(D_sim_rain,i,Hp);
    [D_sim_sim, D_sim_sim_f] = forecast(D_sim_rain_uncertain,i,Hp);
    
    tic
    % Optimization
    [U_opt_Hp,mu_X_opt,sigma_X_opt,lam_g,x_init,mu_D_opt,XI_opt,EPS_opt,dU_opt] = OCP(X_sim_GP(:,i),D_sim_sim_f,sigma_X0_sim,...
                          Z_train_subset,Y_train_subset,GP.sigma_f,lam_g,x_init,inv_K_xx_val,u_prev,Time(i:i+Hp-1));
    toc
    
    % Logged data along Hp
    mu_X_opt_log{i} = full(mu_X_opt(:,:));
    XI_opt_log{i}   = full(XI_opt(:,:)); 
    EPS_opt_log{i}  = full(EPS_opt(:,:));
    dU_opt_log{i}   = full(dU_opt(:,:));
    
    % Solutions
    U_opt(:,i) = full(U_opt_Hp(:,1)); 
    
    u_prev = U_opt(:,i);
    Z_pred = [full(mu_X_opt); full(U_opt_Hp); D_sim_sim_f; Time(i:i+Hp-1)];
    mu_D(:,i) = full(mu_D_opt);
    
    % KPIs
    sigma_Hp_trace = 0;
    for j = 1:Hp
        sigma_Hp_trace = sigma_Hp_trace + trace(full(sigma_X_opt(:,(j-1)*Nx+1:j*Nx)));
    end
    
    KPI_u(i) = (1/Hp)*sum(sumsqr(full(dU_opt)));                                        % smoothening
    KPI_sigma(i) = (1/Hp)*sigma_Hp_trace;                                               % uncertainty
    KPI_s(i)    = (1/Hp)*sum(sum(full(XI_opt)));                                        % safety violation 
    KPI_o(i)    = (1/Hp)*sum(sum(full(EPS_opt)));                                       % overflow

    % Subset of Data (SoD) point selection
    OCP_results{i} = get_stats(OCP);                                                     % Get results
    %if OCP_results{i}.success == 1    
    %   Z_pred_backup = Z_pred; 
    %end
    %if OCP_results{i}.success == 1 || i <10 
    tic
    [Z_train_subset, Y_train_subset] = reduce_M(Z_pred,GP.z_train,GP.y_train,Hp,M);
    Z_train_subset(end,:) = Time(i:i+((M/Hp)*Hp)-1);
    toc
    %elseif OCP_results{i}.success == 0 && i > 10
    %   Z_pred = Z_pred_backup;
    %end
    
    % Quantify point distances ** Test **
    %dist_pred_calculator;
    
    % Build K_xx based on the point selection
    K_xx_builder;                                                                        

    % Dynamics simulator
    X_sim(:,i+1) = full(F_integral_sim(X_sim(:,i), U_opt(:,i), D_sim(:,1 + (i-1)*t_resample), P_sim, dt_MPC ));
    % State update for the GP
    X_sim_GP(:,i+1) = [X_sim(1,i+1); X_sim(2,i+1); X_sim(6,i+1)];
    
    % Learn new datapoints
    if mod(i,2) == 0   % learn every 2nd datapoint 
    GP.z_train = [GP.z_train, [X_sim_GP(:,i); U_opt(:,i); D_sim_sim_f(:,1); Time(i)]];
    GP.y_train = [GP.y_train, X_sim_GP(:,i+1) - (A*X_sim_GP(:,i) + B*U_opt(:,i) + E*D_sim_sim_f(:,1) + [0;0;c4])];
    end
    
    % real time plot
    progressbar(i/N)
    
    if PlotType == 2
        D_sim_sim_plot = [D_sim_sim_plot, D_sim_sim(:,end)];
        D_sim_sim_f_plot = [D_sim_sim_f_plot, D_sim_sim_f(:,end)];
    end

    plotEvery = 1;
    if PlotType == 2
        if mod(i,plotEvery)==0
            drawPlots_uncertainty;
            drawnow
         end
    end
end

%% Static plots
if PlotType == 1
  plotResults;      
end

%%
saveEnabler = 0;
if saveEnabler == 1
    time = datestr(now, 'ddmmyy_HHMM');
    filename = sprintf('./Workspace/NumResults_%s.mat',time);
    save(fullfile(filename)'); 
end

%% Save for GP training

% z_retrain = GP.z_train;
% y_retrain = GP.y_train;
% 
% save('.\training_set tests\z_retrain','z_retrain')
% save('.\training_set tests\y_retrain','y_retrain')

%  x_retrain = X_sim_GP(:,1:end-1);
%  u_retrain = U_opt;
%  d_retrain = D_sim(:,1:t_resample:size(U_opt,2)*t_resample);
%  
%  z_retrain = [x_retrain; u_retrain; d_retrain; Time(1:length(x_retrain))];
%  
%  save('.\training_set tests\z_retrain','z_retrain')
 
% % % 
% save('x_retrain','x_retrain')
% save('u_retrain','u_retrain')
% save('d_retrain','d_retrain')

%% test
testTrue = 0;
if testTrue == 1
dim_select = 3;
step_select = 1500;

t = t_init:t_init+Hp-1;

plot(X_sim(dim_select,:),'*')
hold on

for i = t_init:step_select
plot(t,mu_X_opt_log{i}(dim_select,:))
hold on
t = t + 1;
end
end
