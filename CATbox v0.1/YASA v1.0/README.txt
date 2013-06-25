YASA version 1.0
----------------
YASA is a sinusoidal + variable bandwidth noise analysis method.
It represents a sound as a set of frequencies, amplitudes and 'noisality' parameters. 
Noisality consists of a noisality index and bandwidth.

The method operates by comparison between filtered noise (AR) and sinusoidal beamforming (MVDR) spectral representations, choosing the optimal one at every frequency. YASA uses a constant number of parameters to represent the spectrum. The number of parameters should be at least twice the number of expected sinusoids and should be increase in case of a noisy signal.

The method works for monophonic (single pitch) or polyphonic (multiple pitch) signals. Approximate resynthesis is provided using constant or variable bandwith.

Example:
-------------

% Read a sound file
[z,fs] = wavread('svega.wav')

% YASA analysis
[f,m,n,T] = yasa(z,512,2,80,fs);

% tracking: arranging f,m,n into continuous "voices"
[F,M,N] = maketracks(f,m,n);

% sinusoidal + noise resynthesis[zs,zn] = synthsntrax(F,M,N,fs,512/2,150);

List of programs:
yasa.m - main analysis method
pmvdr.m - power spectrum analysis using AR and MVDR methods
maketracks.m - arranges yasa results into tracks for resynthesis
synthsntrax.m - resynthesis using constant bandwidth noise

References:
S.Dubnov, "YASAS - Yet another sound analysis-synthesis method", ICMC 2006.
YASA is also a secret written code of law created by Genghis Khan http://en.wikipedia.org/wiki/Yasa

Copyright: 
sdubnov@ucsd.edu, 2006Feb20. See also Licence.txt




