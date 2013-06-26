function [m,v,w,lp,f]=gaussmix(x,c,l,m0,v0,w0)
%GAUSSMIX fits a gaussian mixture pdf to a set of data observations [m,v,w,lp]=(x,xv,l,m0,v0,w0)
%
% n data values, k mixtures, p parameters, l loops
% Inputs:
%     X(n,p)   Input data vectors, one per row.
%     c(1,p)  Minimum variance (can be a scalar if all components are identical)
%     L        The integer portion of l gives a maximum loop count. The fractional portion gives
%              an optional stopping threshold. Iteration will cease if the average increase in
%              log likelihood density per data point is less than this value. Thus l=10.001 will
%              stop after 10 iterations or when the average increase in log likelihood falls below
%              0.001.
%     M0(k,p)  Initial mixture means, one row per mixture. Alternatively set M0 to the number of
%              mixtures that are wanted and omit V0 and W0; in this case the kmeans algorithm
%              is used for initialisation.
%     V0(k,p)  Initial mixture variances, one row per mixture.
%     W0(k,1)  Initial mixture weights, one per mixture. The weights should sum to unity.
%
% Outputs:
%     M(k,p)   Mixture means, one row per mixture.
%     V(k,p)   Mixture variances, one row per mixture.
%     W(k,1)   Mixture weights, one per mixture. The weights will sum to unity.
%     LP       Total log probability of the input data.
%     F        Fisher's F ratio measures how well the data divides into classes.

%      Copyright (C) Mike Brookes 2000
%
%      Last modified Tue Oct 15 07:15:58 2002
%
%   VOICEBOX is a MATLAB toolbox for speech processing. Home page is at
%   http://www.ee.ic.ac.uk/hp/staff/dmb/voicebox/voicebox.html
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   This program is free software; you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation; either version 2 of the License, or
%   (at your option) any later version.
%
%   This program is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You can obtain a copy of the GNU General Public License from
%   ftp://prep.ai.mit.edu/pub/gnu/COPYING-2.0 or by writing to
%   Free Software Foundation, Inc.,675 Mass Ave, Cambridge, MA 02139, USA.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[n,p]=size(x);
x2=x.^2;
if length(c)>1
    c=c(ones(k,1),:); % bug - k is undefined
end
if nargin<4,
    k=m0;
    disp('K-means init ...')
    [m,e,j]=kmeans(x,k);
    v=zeros(k,p);
    w=zeros(k,1);
    for i=1:k
        s=i==j;
        v(i,:)=mean(x2(s,:))-m(i,:).^2;
        w(i)=sum(s)/n;
    end
elseif nargin < 6,
    k = size(m0,1);
    disp('K-means init ...')
    [m,e,j]=kmeans(x,k,m0);
    v=zeros(k,p);
    w=zeros(k,1);
    for i=1:k
        s=i==j;
        v(i,:)=mean(x2(s,:))-m(i,:).^2;
        w(i)=sum(s)/n;
    end
else
    k=size(m0,1);
    m=m0;
    v=v0;
    w=w0;
end
v=max(v,c);
im=repmat(1:k,1,n); im=im(:);
ix=repmat(1:n,k,1); ix=ix(:);
th=(l-floor(l))*n;
lp=0;
wk=ones(k,1);
wp=ones(1,p);
wn=ones(1,n);

% EM loop
disp('EM loop ...')
for j=1:l
    vi=v.^(-1);
    vm=sqrt(prod(vi,2)).*w;
    vi=-0.5*vi;
    % Next three lines are equivalent to the one below but with less danger of underflow
    %          px=reshape(exp(sum((x(ix,:)-m(im,:)).^2.*vi(im,:),2)).*vm(im),k,n);
    px=reshape(sum((x(ix,:)-m(im,:)).^2.*vi(im,:),2),k,n);
    mx=max(px,[],1);
    px=exp(px-mx(wk,:)).*vm(:,wn);
    ps=sum(px,1);
    px=px./ps(wk,:);
    pk=sum(px,2);
    w=pk/n;
    m=px*x./pk(:,wp);
    v=px*x2./pk(:,wp);
    v=max(v-m.^2,c);
    lp0=lp;
    lp=sum(log(ps))+sum(mx);
    if j>1 & lp<=lp0+th 
        break; end
end
if nargout > 3
    lp=lp-0.5*p*log(2*pi);
    if nargout > 4
        mm=sum(m,1)/k;
        f=prod(sum(m.^2,1)/k-mm.^2)/prod(sum(v,1)/k);
    end
end