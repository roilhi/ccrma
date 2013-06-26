function ncell = nmat2ncel(nmat,q)
% ncell = nmat2ncel(nmat,q)
% note matrix to note cell. There are 4 note cells for each quantized duration.
%
% Input:
% nmat - note matrix
% q - quantization parameter
% Output:
% ncell - notes cell
%   ncel{1} contains midi pitches. Silence are zero, onsets are negative
%   ncel{2} contains velocities of onsets. Held notes vel. is -1
% (c) Shlomo Dubnov sdubnov@ucsd.edu

% Comments:
% Previously the notes cell contained holding notes as individual cells.
% It seems that a better choice is to divide nmat into objects that occur at note onsets.
% Each object contains all active notes at object onset time.
% Notes are held from pervious notes are marked with a minus sign.
% The duration of the object appeas in 3rd column.
% Duration is until onset of next object.

% Modified 10-8-06

if nargin == 1,
    q = 1/16;
end
nq= quantize(nmat,q,q);
p = nq(:,[1 2 4 5]);
%onset time and durations are turned into integers (cell index)
p(:,1) = p(:,1)/q/4;
p(:,2) = p(:,2)/q/4;
p = ceil(p);

clear pc
len = size(p,1);
dur = max(p(:,1)+p(:,2));
pc = cell(dur,2);
onflag = zeros(dur,1); %onset flag

for i = 1:len,
    ind = [p(i,1)+1:p(i,1)+p(i,2)];
    if ~isempty(ind),
        onflag(ind(1)) = 1;
        onflag(ind(end)+1) = 1;
    end
    onset = 1;
    for j = ind,
        if onset
            pc{j,1} = cat(2, pc{j,1}, p(i,3));
            pc{j,2} = cat(2, pc{j,2}, p(i,4));
            onset = 0;
        else
            pc{j,1} = cat(2, pc{j,1}, -p(i,3)); %held note is marked as negative
            pc{j,2} = cat(2, pc{j,2}, -1); %velocity of a held note is marked as -1
        end
    end
end

%Sorting according to midi numbers
for i = 1:length(pc),
    [Y,I] = sort(abs(pc{i,1}));
    pc{i,1} = pc{i,1}(I);
    pc{i,2} = pc{i,2}(I);
end

%The event onsets are consequtive
ontime = find(onflag);
holddur = diff(ontime);
%holddur(end+1) = dur - ontime(end);

ncnum = sum(onflag(1:end-1)); %number of onset events at different times (grid instance)
ncell = cell(ncnum,3);

for i = 1:ncnum,
    ncell{i,1} = pc{ontime(i),1};
    ncell{i,2} = pc{ontime(i),2};
    ncell{i,3} = holddur(i);
end