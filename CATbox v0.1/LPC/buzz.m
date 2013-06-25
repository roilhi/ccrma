function ex = buzz(f0,nsamp,fs)
% ex = buzz(f0,nsamp,fs)
% A very inefficient way of generating a band-limited pulse train (up to fs/2)
% f0 - fundamental
% nsamp - duration (in samples)
% fs - sampling freq.
% (c) Shlomo Dubnov sdubnov@ucsd.edu

theta = 2*pi*f0/fs*([1:fs/f0/2]'*[0:nsamp-1]);
ex = ones(1,size(theta,1))*cos(theta);

