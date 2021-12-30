%% Build training sets
% Training set structure: [x1,x2,x3,x4,x5,x6,u1,u2,d1,d2,d3] (nz x N)

C = cell(Nx,1);                                                                  % individual training set for each GP
nz = 11;%size(z,1);
               %[1,2,3,4,5,6,7,8,9,10,11]
dim_select_C1 = [1,7,9];
dim_select_C2 = [6,7,8,11];%[2,3,4,5,6,7,8,11];
dim_select_C3 = [3,4,7];
dim_select_C4 = [3,4,5,7,11];
dim_select_C5 = [4,5,6,7,11];
dim_select_C6 = [5,6,7,11];

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
% Mapping matrix for output 6: 
C{6} = zeros(size(dim_select_C6,2),nz);
for i = 1:size(dim_select_C6,2)
    C{6}(i,dim_select_C6(i)) = 1;
end