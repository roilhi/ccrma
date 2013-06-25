function [X] = makeObservationMatrix(x,fs, TYPE)

%--------------------------------------------------------------------------------------
% Perform time-frequency transformation. It can be Magnitude spectra or something else.
%
% Input : TYPE - see Commmon.m for observation matrix type definitions
%--------------------------------------------------------------------------------------


% Magnitude-spectra transformation
switch TYPE
    case 'MAG',
        %nx = length(x);
        nfft = 256;
        nwind = nfft;
        noverlap = ceil(nwind/2);
        %figure;specgram(x,nfft, fs, [],noverlap);
        B = specgram(x,nfft, fs, [],noverlap);
        %title(sprintf('Original signal -  %s',s_title));
        B = abs(B);

        X = B';

    case 'ENV',
        [X,sumX,sumXX,Bands]=AudioSpectrumEnvelope(x', fs,4);
        X(X==0) = eps;   % avoide log of zero
        X = 10*log10(X);
        X = normcolumns(X);

        X = X';

    case 'ERB',

        NUM_CHANNELS = 25;

        % Prepare filterbank coefficients
        fcoefs = MakeERBFilters(fs, 25,0);

        % Do actual processing
        X = ERBFilterBank(x,fcoefs);

        % We need the coefficients in columns
        X = X';

end


function V = normcolumns(V)


delta = sqrt(sum(V.*V));
% cannot invert if any delta is singular, i.e. if close to 0
% Catch error and fix somehow
% Since V is zero at that index, invdelta divides by 1 there
ind = find(delta);
invdelta = ones(1,length(delta));
invdelta(ind)=1./delta(ind);
invdelta = repmat(invdelta,size(V,1),1);
V=V.*invdelta;
