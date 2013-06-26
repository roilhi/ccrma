function nc2 = xseq2ncel(xs,ncx);
% nc2 = xseq2ncel(xs,ncx)
% Input:
% ncx - note cell with cross alphabet
% xs - sequence of cross alphabet symbols
% Output:
% nc2 - note cell according to x2
% (c) Shlomo Dubnov sdubnov@ucsd.edu

ncxi = cell2mat(ncx(:,4));
for i = 1:length(xs),
    j = min(find(ncxi==xs(i)));
    nc2{i,1} = ncx{j,1};
    nc2{i,2} = ncx{j,2};
    nc2{i,3} = ncx{j,3};
end
