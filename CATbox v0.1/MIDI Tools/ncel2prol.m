function pr = ncel2prol(nc,format)
% pr = ncel2prol(nc)
% pr = piano roll matrix
% nc = note cell matrix
% (c) Shlomo Dubnov sdubnov@ucsd.edu

dur = cell2mat(nc(:,3));
totdur = sum(dur);
%time = [1; cumsum(dur)];
time = [1; cumsum(dur)+1];
pr = zeros(128,totdur);
for i = 1:length(nc)
    for j = 1:length(nc{i}),
        note = nc{i,1}(j);
        vel = nc{i,2}(j);
        non = note > 0;
        if non,
            pr(note,time(i):time(i+1)-1) = vel; %note on during object duration           
        else
            note = abs(note);
            pr(note,time(i):time(i+1)-1) = pr(note,time(i)-1); %continue with previos velocity of same note
        end
    end
end