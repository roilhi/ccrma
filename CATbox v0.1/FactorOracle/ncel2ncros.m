function nx = ncel2ncros(nc, method)
% nx = ncell2ncross(nc)
% notes cell to cross alphabet
% input:
% nc - notes cell
% method - 1 = notes only (default), 2 = notes and duration
% output:
% nc - vector contraining the sequence of cross alphabet symbols
%
% Note: this might take a while in case that the cross alphabet is big.
% (c) Shlomo Dubnov sdubnov@ucsd.edu

if nargin == 1,
    method = 1;
end

tic
xi = 1;
nx = cell(size(nc,1),size(nc,2)+1);
nx(:,1:3) = nc;
nx{1,4} = xi;
xi = xi+1;
for i = 2:length(nc),
    %i
    for j=i-1:-1:1,
        %        if strcmp(num2str(pc{i,1}),num2str(pc{j,1})),
        nci = nc{i,1}; ncj = nc{j,1};            
        if length(nci)==length(ncj),
            if nci == ncj,
                switch method
                    case 1                    
                        nx(i,4) = nx(j,4);
                        break
                    case  2
                        %                        if nc{i,3} == nc{j,3}, %Memex 1
                        durrat = nc{i,3}/nc{j,3}; %Memex 2
                        if durrat < 2 & durrat > 0.5
                            nx(i,4) = nx(j,4);
                            break
                        end
                    otherwise
                        error('no such method');
                end
            end
        end
        if j == 1,
            nx{i,4} = xi;
            xi = xi+1;
        end
    end
end
toc

