function [X,Y] = synthsntrax(F, M, N, SR, SUBF, bw, DUR)
% [X,Y] = synthsntrax(F, M, D, SR, SUBF, bw, DUR)      
% Reconstruct a sound from track representation, including noise and time
% stretching.
%	Each row of F and M contains a series of frequency and magnitude 
%	samples for a particular track.  These will be remodulated and 
%	overlaid into the output sound X which will run at sample rate SR, 
%	although the columns in F and M are subsampled from that rate by 
%	a factor SUBF (default 128).  N is the noise factor matrix. N = 1 means 
%   sinusoid and N = 0 means noise. bw is the noise bandwidth (default 150Hz). 
%   DUR is a time stretch factor, so that 1 is no change, > 1 is
%   stretching, < 1 contraction.
% sdubnov@ucsd.edu 2006feb20; modified from dpwe@icsi.berkeley.edu


if(nargin<5)
  SUBF = 128;
end


if(nargin<6)
  bw = 150;
end


if(nargin<7)
  DUR = 1;
end

SUBF = SUBF*DUR;

rows = size(F,1);
cols = size(F,2);

opsamps = 1 + ((cols-1)*SUBF);

X = zeros(1, opsamps);
Y = zeros(1, opsamps);

bwn = bwrandn(opsamps,bw/SR*2); %assuming 150Hz for 16000 sampling frequency
  
progressbar(0)

for row = 1:rows
    %if rem(row,10) == 0,
    %    disp(['row ' int2str(row) ' out of ' int2str(rows)])
    %end
    %  fprintf(1, 'row %d.. \n', row);
  mm = M(row,:);
  ff = F(row,:);
  nn = N(row,:);
  % Where mm = 0, ff is undefined.  But interp will care, so find points 
  % and set.
  % First, find onsets - points where mm goes from zero (or NaN) to nzero
  % Before that, even, set all nan values of mm to zero
  mm(find(isnan(mm))) = zeros(1, sum(isnan(mm)));
  ff(find(isnan(ff))) = zeros(1, sum(isnan(ff)));
  %nn(find(isnan(nn))) = ones(1, sum(isnan(nn)));
  nn(find(isnan(nn))) = zeros(1, sum(isnan(nn)));
  nzv = find(mm);
  firstcol = min(nzv);
  lastcol = max(nzv);
  % for speed, chop off regions of initial and final zero magnitude - 
  % but want to include one zero from each end if they are there 
  zz = [max(1, firstcol-1):min(cols,lastcol+1)];
  mm = mm(zz);
  ff = ff(zz);
  nn = nn(zz);
  nzcols = prod(size(zz));
  mz = (mm==0);
  mask = mz & (0==[mz(2:nzcols),1]);
  ff = ff.*(1-mask) + mask.*[ff(2:nzcols),0];
  % Do offsets too
  mask = mz & (0==[1,mz(1:(nzcols-1))]);
  ff = ff.*(1-mask) + mask.*[0,ff(1:(nzcols-1))];
  % Ok. Can interpolate now
  % This is actually the slow part
%  % these parameters to interp make it do linear interpolation
%  ff = interp(ff, SUBF, 1, 0.001);
%  mm = interp(mm, SUBF, 1, 0.001);
%  % chop off past-the-end vals from interp
%  ff = ff(1:((nzcols-1)*SUBF)+1);
%  mm = mm(1:((nzcols-1)*SUBF)+1);
  % slinterp does linear interpolation, doesn't extrapolate, 4x faster
  ff = slinterp(ff, SUBF);
  mm = slinterp(mm, SUBF);
  nn = slinterp(nn, SUBF);
% convert frequency to phase values
  pp = cumsum(2*pi*ff/SR);
  % bandlimited interpolation for the modulation noise
  %alpha = 7;
  %I = 1;
  %aa = (exp(alpha*(1-nn))-1)/(exp(alpha)-1); %noise factor (amplitude)  
  
  kk = 1-nn;
  
  % This is a slow part. At risk of using same noise samples, we do it once
  % at the beginning and just read the file
  %xn = bwrandn(length(nn),bw/SR*2); %assuming 150Hz for 16000 sampling frequency
  
  ind = ceil(rand*(opsamps-length(mm)+1));
  xx = mm.*sqrt(1-kk.^2).*cos(pp);
  xn = mm.*kk/2.*bwn(ind:ind+length(mm)-1).*cos(pp);
  
  %xx = mm.*sqrt(nn).*cos(pp);
  %xn = mm.*sqrt(1-nn).*xn.*cos(pp);
  
  %bwn = bwrandn(length(nn),150/SR*2); %assuming 30Hz for 16000 sampling frequency
  %pn = I*pi*aa.*bwn;
  % run the oscillator and apply the magnitude envelope
  %xn : generate bandlimited noise in the "Hinich" style?
  %xx = mm.*cos(pp+pn);
  % add it in to the correct place in the array
  base = 1+SUBF*(zz(1)-1);
  sizex = prod(size(xx));
  ww = (base-1)+[1:sizex];
  X(ww) = X(ww) + xx;
  Y(ww) = Y(ww) + xn;
  
  progressbar(row/rows)
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Helper function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Y = slinterp(X,F)
% Y = slinterp(X,F)  Simple linear-interpolate X by a factor F
%        Y will have ((size(X)-1)*F)+1 points i.e. no extrapolation
% dpwe@icsi.berkeley.edu  fast, narrow version for SWS

% Do it by rows

sx = prod(size(X));

% Ravel X to a row
X = X(1:sx);
X1 = [X(2:sx),0];

XX = zeros(F, sx);

for i=0:(F-1)
  XX((i+1),:) = ((F-i)/F)*X + (i/F)*X1;
end

% Ravel columns of X for output, discard extrapolation at end
Y = XX(1:((sx-1)*F+1));


function s = bwrandn(N,bw);
if nargin == 1,
    bw = 1;
end

% ns = ceil(N*bw); %number of random samples to start with (bw fraction of N)
% 
% s = interp(randn(1,ns),ceil(1/bw));
% s = s(1:N);

[B,A] = butter(3,bw);
s =  filter(B,A,randn(1,N));
s = s/std(s);
