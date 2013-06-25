function [f,A,n,ra,Sa,Sb] = pmvdr(x,p,beta,Nfft,fs)
% [f,A,n,bw,Sa,Sb] = pmvdr(x,p,beta,Nfft)
% mvdr power spectrum of x
% p - order of MVDR filter (and equivalent LPC filter)
% beta - noisal threshold in dB
% Nfft - spectral resolution (used for display and periodogram comparison)
% output:
% f,A,n - analysis results: frequencies, Amplitudes and "Noisality"
% ra - roots of the lpc polynomial
% Sa, Sb - AR and MVDR power spectral estimates
%
% copyright Shlomo Dubnov sdubnov@ucsd.edu, 2006Feb20, 
% Modified 2006Oct14

%for debugging purposes
PLT = 0;
PRNT = 0;

if nargout == 0,
    PLT = 1;
end

if nargin < 3,
    beta = 3; %3dB 
end

if nargin < 4,
    Nfft = 512;
end

x = x-mean(x); %avoid DC

%tic
[a,e] = lpc(x,p);
lenx = length(x);
%toc

%tic
for k = 0:p,
    i = [0:p-k];
    mu(k+1) = sum((p+1-k-2*i).*a(i+1).*conj(a(i+1+k)));
end
%toc

mu = [conj(mu(end:-1:2)) mu]/e;
lmu = length(mu);

%tic
% Spectral Factorization of a and mu
ra = roots(a);
ra = ra(find(angle(ra)>0 & angle(ra)<pi));
%ra = ra(find(angle(ra)>0 & angle(ra)=<pi)); %Shlomo 1 June
aa = angle(ra);

rb = roots(mu);
rb = rb(find(abs(rb)<=1));
rb = rb(find(angle(rb)>0 & angle(rb)<pi));
ab = angle(rb);
[ab,I] = sort(ab);
rb = rb(I);
%toc

%Estimating the amplitudes at precise frequencies
Pra = exp(-sqrt(-1)*aa*[0:(lmu-1)/2])*a';
Aa = e./abs(Pra).^2/(p+1); %/lenx;

Prb = real(exp(-sqrt(-1)*aa*[-(lmu-1)/2:(lmu-1)/2])*mu');
Ab = 1./Prb;

%bandwith of the pole can be evaluated using the following relations
%pole_radius = exp(-pi*bandwidth/fs)
%b = -log(abs(ra))/pi*fs
%since we do not necessarily pass fs here, this calculation is left out of this
%function.

d = 10*log10(Aa./Ab);

% YASA: mvdr amplitdues (Ab) with lpc frequencies (ra1)
A = sqrt(2*Ab);
%rc = ra1;
f = aa/pi;

% noisailty
alpha = 0.1;
n = (tanh(2*pi*alpha.*(d-beta))+1)/2; 

if nargout >=5 | PLT,
    % Calculating the spectra of the two models
    Wmat = exp(-sqrt(-1)*2*pi/Nfft*[0:Nfft/2-1]'*[0:(lmu-1)/2]);
    Pwa = Wmat*a';
    Sa = e./abs(Pwa).^2/(p+1); %/lenx;

    Wmat = exp(-sqrt(-1)*2*pi/Nfft*[0:Nfft/2-1]'*[-(lmu-1)/2:(lmu-1)/2]);
    Pwb = real(Wmat*mu');
    Sb = 1./Pwb;

    Sp = abs(fft(x,Nfft))/Nfft;
    Sp = Sp(1:Nfft/2).^2;
end

if PLT,

    
    if nargin<5, fs = 2; end 
    
    [f1,if1] = sort(f);
    for i = 1:length(f),
    fprintf('freq = %6.2f, d = %f \n',f1(i)*fs/2, d(if1(i)))
    end
    
    figure(1)
    plot([0:Nfft/2-1]/Nfft*fs,10*log10(Sb),'ro-')
    hold on
    plot([0:Nfft/2-1]/Nfft*fs,10*log10(Sa))
    plot([0:Nfft/2-1]/Nfft*fs,10*log10(Sp),'gx-')
    th = title('LPC, MVDR and Periodogram Spectrum');
    set(th,'FontSize',18)
    xlabel('Frequency')
    ylabel('Amplitude')
    legend(['MVDR     '; 'LPC      '; 'Periodgrm';])
    hold off

    if 1,
    figure(2)
    zplane(1,a)
    hold on
    plot(rb,'xr')
    %plot(rc,'og')
    hold off
    end
    
    if PRNT,
        fprintf('%s \n','****')
        for i = 1:length(A), %p/2+1:p,
            fprintf('%6.4f %6.2f %6.4f\n',f(i),10*log10(A(i)),n(i))
        end
    end
   
    pause

    
    
end
