function [p,q,D] = align(S,type,ins,del,thresh)
% [p,q,D] = dtw(S,type,in,del,thresh) or [p,q,D] = dtw(S,type,thresh)
% S = similarity matrix between two seqeunces
% ins,del = deletion and insertion penalties
% thresh = threshold that applies to LCS and TWLCS methods only.
% type = alignment method. Supported methods are:
% GSA global sequence alignment
% LSA local sequence alignment
% LCS longest common subsequence
% ASM approximate sequence matching
% OLM overlap match
% DTW dynamic time warping
% TWLCS time warped longest common subsequence 
%
% similarity is the cost of moving on a diagonal (advancing together)
% delition and insertions operations are defined in terms of operations
% done on the second (horizontal) sequence, i.e. deletion is the horizontal
% cost (accellerando / speed up) and insertion is the vertical cost
% (ritenuto / wait).
% (c) Shlomo Dubnov sdubnov@ucsd.edu

if nargin == 1,
    type = 'GSA';
end

[r,c] = size(S);

disp(type);

% Initialize
D = zeros(r+1, c+1);
trace = zeros(r+1,c+1);

switch type,
    case 'GSA', %like ASM but penalize indels strongly - one indel costs same as two matches
        if nargin < 3, ins = -2; end
        if nargin < 4, del = ins; end
        P = 2*S-1; %S=1 -> p=1; S=0 -> p=-1;
        D(1,1:end) = del*[1:c+1];
        D(1:end,1) = ins*[1:r+1];
        for i = 1:r,
            for j = 1:c,
                [D(i+1,j+1), trace(i+1,j+1)] = max([D(i,j) + P(i,j), D(i+1,j) + del, ...
                    D(i,j+1) + ins]);
            end
        end

    case 'LSA' %local subsequence alignment
        % like GSA but:
        % (1) allows starting new alignment by jumping to the beginning -
        % this adds extra option in max and changes the initialization to 0
        % (2) alignment can end in the middle - changes traceback

        if nargin < 3, ins = -2; end
        if nargin < 4, del = ins; end
        P = 2*S-1; %S=1 -> p=1; S=0 -> p=-1;

        for i = 1:r,
            for j = 1:c,
                %                [D(i+1,j+1), trace(i+1,j+1)] = max([D(i,j) + P(i,j), D(i+1,j) + del*P(i,j), ...
                %                   D(i,j+1) + ins*P(i,j), 0]);
                [D(i+1,j+1), trace(i+1,j+1)] = max([D(i,j) + P(i,j), D(i+1,j) + del, ...
                    D(i,j+1) + ins, 0]);
            end
        end


    case 'OLM' %overlap match
        % like GSA but does not penalize ovehanging ends:
        % (1) starts top or left border - intialize these borders to zero
        % (2) end at the maximal D on the bottom or right border - changes traceback

        if nargin < 3, ins = -2; end
        if nargin < 4, del = ins; end
        P = 2*S-1; %S=1 -> p=1; S=0 -> p=-1;
        for i = 1:r,
            for j = 1:c,
                [D(i+1,j+1), trace(i+1,j+1)] = max([D(i,j) + P(i,j), D(i+1,j) + del, ...
                    D(i,j+1) + ins]);
            end
        end


    case 'LCS' %longest common subsequence abdcedfe, bdef -> -bd-e--f-
        % like GSA but does not penalize indels. Whenever the matching is low
        % it selects best predecessor. Only high P values are used.

        if nargin < 3, thresh = 0.5; else thresh = ins; end
        P = [S > thresh]; %S<0.5 -> p=0, S>0.5 -> p=1;
        for i = 1:r,
            for j = 1:c,
                if P(i,j),
                    [D(i+1,j+1), trace(i+1,j+1)] = max([D(i,j) + P(i,j), 0 0]); 
                else
                    [D(i+1,j+1), trace(i+1,j+1)] = max([0,D(i+1,j),D(i,j+1)]);
                end
            end
        end

        %         P = [S > 0.5]; %S<0.5 -> p=0, S>0.5 -> p=1;
        %         for i = 1:r,
        %             for j = 1:c,
        %                 [D(i+1,j+1), trace(i+1,j+1)] = max([D(i,j) + P(i,j), D(i+1,j), ...
        %                     D(i,j+1)]);
        %             end
        %         end

    case 'ASM' %approximate sequence matching
        % like GSA but keep the ratio of indels versus matching cost lower
        % - indel costs same as poor / no matching.
        if nargin < 3, ins = 1; end
        if nargin < 4, del = ins; end
        P = 1-S; %S=0 -> p=1; S=1 -> p=0;
        D(1,1:end) = del*[1:c+1];
        D(1:end,1) = ins*[1:r+1];
        for i = 1:r,
            for j = 1:c,
                [D(i+1,j+1), trace(i+1,j+1)] = min([D(i,j) + P(i,j), D(i+1,j) + del, ...
                    D(i,j+1) + ins]);
            end
        end

    case 'DTW' %dynamic time warping, Rabiner-Schaefer style (see Orio's paper).
        % indels here are treated as weights of substitution costs. 
		% if indel = 1, it basically chooses the "cheapest" path through P.
        % if indels > 1, it "prefers" paths that are closer to diagonal by
        % penalizing off-diagonal mismatches. DTW works best for cases of
        % repetitions of same symbols (time-warping). In this case the
        % matching costs P(i,j) remain high horizontally or vertically,
        % tracing these paths allows shortening or stretching (time-warping)
        % the sequences.

        if nargin < 3, ins = 1; end %penalize off diagonal matches by a factor of 2
        if nargin < 4, del = ins; end
        P = 1-S; %S=0 -> p=1; S=1 -> p=0;
        D(1,1:end) = del*[1:c+1];
        D(1:end,1) = ins*[1:r+1];
        for i = 1:r,
            for j = 1:c,
                [D(i+1,j+1), trace(i+1,j+1)] = min([D(i,j) + P(i,j), D(i+1,j) + del*P(i,j), ...
                    D(i,j+1) + ins*P(i,j)]);
            end
        end

    case 'TWCLS' %time warped CLS:
        % DTW allows repetitions but penalizes false notes. So shorter
        % correct fragments are preferred to long fragments with few false notes.
        % LCS on the other hand is good at skipping false notes but does not
        % distinguish tempo change (time-warping) from false notes.
        % TWCLS works like LCS in terms that it allows skipping false
        % notes, so whenever the distance is large it prefers indels. On
        % the other hand, if the distance is low such as in the case of
        % time-warping, it chooses the best predecessor including the diagonal.

        if nargin < 3, ins = 1; end
        if nargin < 4, del = ins; end
        if nargin < 5, thresh = 0.5; end

        P = [S > thresh]; %S<0.5 -> p=0, S>0.5 -> p=1;
        for i = 1:r,
            for j = 1:c,
                if P(i,j),
                    [D(i+1,j+1), trace(i+1,j+1)] = max([D(i,j) + P(i,j), D(i+1,j) + del*P(i,j), ...
                        D(i,j+1) + ins*P(i,j)]);
                else
                    [D(i+1,j+1), trace(i+1,j+1)] = max([0, D(i+1,j), D(i,j+1)]);
                end
            end
        end

    otherwise
        error('No such alignment method');
end

% Traceback
if (strcmp(type,'LSA')),
    % start from the the highest matching pair
    [rmax,i] = max(D);
    [cmax,j] = max(rmax);
    i = i(j);
    p = i;
    q = j;
elseif strcmp(type,'OLM'),
    [rend,j] = max(D(end,:));
    [cend,i] = max(D(:,end));
    if rend > cend,
        i = size(D,1);
    else
        j = size(D,2);
    end
    p = i;
    q = j;
else
    i = r+1;
    j = c+1;
    p = i;
    q = j;
end

while i > 1 & j > 1
    indx = trace(i,j);
    %in LSA end when traceback hits a zero match
    if((strcmp(type,'LSA')) & (D(i,j) == 0)),
        return
    end
    if(strcmp(type,'OLM') & (i == 1 | j == 1)),
        return
    end
    if (indx == 1)
        i = i-1;
        j = j-1;
    elseif (indx == 2)
        j = j-1;
    elseif (indx == 3)
        i = i-1;
    elseif (indx == 4) %LSA only
        i = 1;
        j = j-1
    else
        error;
    end
    p = [i,p];
    q = [j,q];

end
