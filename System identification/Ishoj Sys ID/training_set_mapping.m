%% Build training sets
% Definition of the mapping matrices based on the indices in the full
% z = [h_m1'; h_m3'; h_m4'; h_m5'; h_b2'; r']
%       1      2      3      4     5      6                             
                                 
C = cell(Nx,1);                                                     % training set for each GP
nz = size(z,1);

% Original: 
% dim_select_C1 = [2,6];        %                              
% dim_select_C2 = [1,6];                                 
% dim_select_C3 = [1,2,6];    % this is the most downstream level                                     
% dim_select_C4 = [1,2,6];     
% dim_select_C5 = [2,4,6];  

% modified
% dim_select_C1 = [2,3,4,5,6];        %                              
% dim_select_C2 = [1,3,4,5,6];                                 
% dim_select_C3 = [1,2,4,5,6];    % this is the most downstream level                                     
% dim_select_C4 = [1,2,3,5,6];     
% dim_select_C5 = [1,2,3,4,6];  

dim_select_C1 = [2,4];        %                              
dim_select_C2 = [1,4];                                 
dim_select_C3 = [1,2,4,5,6];    % this is the most downstream level                                     
dim_select_C4 = [1,2];     
dim_select_C5 = [1,2,3,4,6];  

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
% Mapping matrix for output 5: 
C{5} = zeros(size(dim_select_C5,2),nz);
for i = 1:size(dim_select_C5,2)
    C{5}(i,dim_select_C5(i)) = 1;
end
