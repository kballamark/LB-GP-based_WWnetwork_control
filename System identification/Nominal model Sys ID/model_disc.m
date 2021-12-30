function [dx, y] = model_disc(t,x,u,a33,a43,a44,b31,b41,c3,c4,varargin)
% Discrete time model for the nominal pipe dynamics in the GP-based MPC
% Parameters: a = [a33,a43,a44] and b = [b31,b41]

dx = zeros(2,1);
y = zeros(2,1);

%% State equation
% dx(1) = a33*x(1) + b31*u(1);
% dx(2) = a43*x(1) + a44*x(2) + b41*u(1);

dx(1) = 0*x(1) + b31*u(1) + c3;
dx(2) = 0*x(1) + 0*x(2) + b41*u(1) + c4;

%dx = [a(1),0; a(2),a(3)] * [x(1);x(2)] + [b(1),0; b(2),0] * [u(1);u(2)];

%% Output equations 
y(1) = x(1);
y(2) = x(2);

%y = [x(1); x(2)];

end