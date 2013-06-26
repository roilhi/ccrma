function nm2 = ncel2nmat(nc,q)
% nm2 = ncel2nmat(nc,q)
% nc = cell arrayh
% q = quantization
% (c) Shlomo Dubnov sdubnov@ucsd.edu

if nargin == 1,
    q = 1/16;
end

pr2 = ncel2prol(nc);
nm2 = prol2nmat(pr2,q);
