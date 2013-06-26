function [F,M,N,BW,T] = yasa(z,win,hopfactor,p,fs,beta)
% [F,M,N,T] = yasa(z,win,hopfactor,p,fs,beta)
if nargin < 2, win = 1024; end
if nargin < 3, hopfactor = 4; end
if nargin < 4, p = 80; end
if nargin < 5, fs = 2; end
if nargin < 6, beta = 6; end

hop = win/hopfactor;
Z = buffer(z,win,win-hop);

% rule of thumb for p = floor(fs/120)*2;

disp(['Analysis order ' int2str(p) ', Sampling Freq ' int2str(fs)])
%disp(['hop ' int2str(hop/fs*1000) 'ms, frame size ' int2str(win)])

%Rules of thumb:
% fs = 22050, p = 70, bw = fs/p or fs/p/2
% fs = 44100, p = 140, bw = fs/p

%F = NaN*ones(p/2-1,size(Z,2)); %F = zeros(p/2,size(Z,2));
F = zeros(p/2-1,size(Z,2)); %F = zeros(p/2,size(Z,2));
M = F;
N = F;
BW = F;

T = hop*[1:size(Z,2)]/fs;
ktop = 1;
oldktop = 0;
progressbar(0);

L = size(Z,2);
for i = 1:L,
%    disp(['frame ' int2str(i) ' of ' int2str(size(Z,2))]);
    %     ktop-oldktop
    %     oldktop = ktop;
    %
    [f,A,n,ra] = pmvdr(Z(:,i),p,beta);
    [fsort,ind] = sort(f);
    lfs = length(fsort);
    if lfs == p/2-1,
        lf = [1:lfs];
    else
        lf = [2:lfs+1];
    end
    F(lf,i) = fsort*fs/2;
    M(lf,i) = A(ind);
    N(lf,i) = n(ind);
    BW(lf,i) = -log(abs(ra(ind)))/pi*fs;
    progressbar(i/L)
end

return

F(find(F==0)) = NaN; %The unassigned tracks are given NaN again (instead of 0)
M(find(F==0)) = NaN;
N(find(F==0)) = NaN;
BW(find(F==0)) = NaN;

keep = sum(~isnan(F)') >= 2;
F = F(find(keep),:);
M = M(find(keep),:);
N = N(find(keep),:);
BW = BW(find(keep),:);
