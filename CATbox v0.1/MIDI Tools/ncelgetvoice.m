function nc2 = ncelgetvoice(nc,expr,fromto)
% nc2 = ncellgetvoice(nc,expr,[N1 N2])
% Extract a voice from polyphonic ncell
% nc = ncell
% expr = can be one of the following:
% 'size' returns the number of voices
% 'melody' returns ncell with top voice
% 'bass' returns ncell with bottom voice
% [N1 N2] = range of cells. default [1 length(nc)]
%
% Example: nc2 = ncellgetvoice(nc,'melody');
% (c) Shlomo Dubnov sdubnov@ucsd.edu

if nargin == 2,
    fromto = [1 length(nc)];
end
range = [fromto(1):fromto(2)];

switch expr
    case 'size',
        nc2 = 0;
        for i=range,
            thisv = length(nc{i,1});,
            if nc2 < thisv,
                nc2 = thisv;
            end
        end
    case 'melody'
        nc2 = cell(1,3);
        for i=range,
            for j = 1:3,
                nc2{i,j} = nc{i,j}(1);
            end
        end
    case 'bass'
        nc2 = cell(1,3);
        for i=range,
            for j = 1:3,
                nc2{i,j} = nc{i,j}(end);
            end
        end
end


