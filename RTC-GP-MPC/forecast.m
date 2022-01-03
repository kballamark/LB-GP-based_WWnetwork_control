function [D_sim_sim, D_sim_sim_f] = forecast(D_sim,i,Hp)

D_sim_sim = D_sim(:,(i)*(20)-19:20:(i-1)*20 + (Hp)*20-19);                          % not used

%D_sim_sim_f = abs(D_sim(:,(i)*(20)-19:20:(i-1)*20 + (Hp)*20-19) + randn(3,Hp)*0.5);        % imperfect forecast

D_sim_sim_f = D_sim(:,(i)*(20)-19:20:(i-1)*20 + (Hp)*20-19);                        % make the uncertainty for the entire historic dataset

end

%%

