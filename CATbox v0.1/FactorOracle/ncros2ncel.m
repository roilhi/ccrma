function nc2 = ncros2ncel(ncx,x2);
% nc2 = ncros2ncel(ncx,x2)
% Input:
% ncx - note cell with cross alphabet
% x2 - sequence of cross alphabet symbols
% Output:
% nc2 - note cell according to x2
% (c) Shlomo Dubnov sdubnov@ucsd.edu

for i = 1:length(x2),
    ncxi = cell2mat(ncx(:,4));
    j = min(find(ncxi==x2(i)));
    nc2{i,1} = ncx{j,1};
    nc2{i,2} = ncx{j,2};
    nc2{i,3} = ncx{j,3};
end
