%% Build training sets
% Definition of the mapping matrices based on the indices in the full
% training set given for the comvined WW + rain and separated WW - rain
% z = [x1,x2,x3,x4,u1,u2,d1,d2,d3,t]
%       1  2  3  4  5  6  7  8  9 10                                 
                                 
C = cell(Nx,1);                                                     % training set for each GP
nz = size(z,1);

% Separated WW & Rain
%     dim_select_C1 = [7,10]; % [1,5,7,10]                            % tank 1
%     dim_select_C2 = [4,6]; % [2,4,6]                                % tank 2
%     dim_select_C3 = [3,5];   % [3,5]                                % pipe 1
%     dim_select_C4 = [3,4,10];       %[3,4,5,10];                    % pipe 2  % exclude 9 only because it is zero,i.e., there is no rain
%     
    dim_select_C1 = [7,10]; % [1,5,7,10]                            % tank 1
    dim_select_C2 = [4,6]; % [2,4,6]                                % tank 2
    dim_select_C3 = [5,10];   % [3,5]                                % pipe 1
    dim_select_C4 = [3,5,10];       %[3,4,5,10];                    % pipe 2  % exclude 9 only because it is zero,i.e., there is no rain

% Mapping matrix for output 1: 
C{1} = zeros(size(dim_select_C1,2),nz);
for i = 1:size(dim_select_C1,2)
    C{1}(i,dim_select_C1(i)) = 1;
end
% Mapping matrix for output 2: 
C{2} = zeros(size(dim_select_C2,2),nz);
for i = 1:size(dim_select_C2,2)
    C{2}(i,dim_select_C2(i)) = 1;
end
% Mapping matrix for output 3: 
C{3} = zeros(size(dim_select_C3,2),nz);
for i = 1:size(dim_select_C3,2)
    C{3}(i,dim_select_C3(i)) = 1;
end
% Mapping matrix for output 4: 
C{4} = zeros(size(dim_select_C4,2),nz);
for i = 1:size(dim_select_C4,2)
    C{4}(i,dim_select_C4(i)) = 1;
end
