function nm2 = prol2nmat(pr,q)
% nm2 = prol2nmat(pr,q)
% Input: 
% pr - piano roll. Could  be in format 1 or 2 (velocities or onset values)
% q - quantization factor
% Output: 
% nm2 - note matrix
% Play midifile from PR2 format of prmat (piano roll)
% (c) Shlomo Dubnov sdubnov@ucsd.edu

if prod(double(ismember(pr,[-1:2]))),
    PR = 2;
    pr2 = pr;
    % pr2: contains note on, held notes and note off values
    % All velocities are set to 100
    disp('piano roll is in format 2 (onsets)')
else
    disp('piano roll is in format 1 (velocities)')
    PR = 1;
    pr = [pr zeros(size(pr,1),1)];
    prb = pr>0;
    pr1 = [zeros(size(prb,1),1) prb];
    prd = diff(pr1,1,2);
    pr2 = prb+prd;
    % pr2: contains note on, held notes and note off values
end

Quant = 1/q/4;

k = 1;
nm2 = zeros(1,7);
for i = 1:128, %for every midi values 1:128
    non = find(pr2(i,:)==2); %find note on indices
    noff = find(pr2(i,:)==-1); %find note off indices
    if ~isempty(non),
        dur = noff-non-1; %durations
        for j = 1:length(non),
            if PR == 1,
               % nm2(k,:) = [non(j)/Quant dur(j)/Quant 1 i 100 non(j)/Quant dur(j)/Quant]';
                nm2(k,:) = [non(j)/Quant dur(j)/Quant 1 i pr(i,non(j)) non(j)/Quant dur(j)/Quant];
            else
                nm2(k,:) = [non(j)/Quant dur(j)/Quant 1 i 100 non(j)/Quant dur(j)/Quant];
            end
            % nm2(k,:) = [non(j) dur(j) 1 i 100 non(j)/Quant dur(j)/Quant]';
            k = k+1;
        end
    end
end

% playmidi does the sorting!
% I = sort(nm2(:,1)); ...
