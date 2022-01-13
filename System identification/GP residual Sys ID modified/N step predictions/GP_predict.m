function [pred,ci] =  GP_predict(i,j,n,gps,C,x_hat,z,num_x,Nx)

[pred,~,ci] = predict(gps{j}, [C{j}(1:num_x(j),1:Nx)*x_hat(:,i); C{j}(num_x(j)+1:end,:)*z(:,n+i-1)]');
