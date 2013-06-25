function [F,M,N,BW] = maketracks(f,m,n,bw,Fmin,Fmax,Aratio)
%[F,M,N,BW] = maketracks(f,m,n,bw,Fmin,Fmax,Aratio)
% make synthesis tracks out of YASA analysis.
% f,m,n,bw - YASA results
% Fmin, Fmax - allowed frequency deviation to still account as track
% continuation
% Aratio - allowed amplitude deviation to account as one track

if nargin<5, Fmin = 1/1.06; end %semitone
if nargin<6, Fmax = 1.06; end
if nargin<7, Aratio = 6; end %allowed change in dB

valoc = zeros(1,size(f,1)*2); %voice allocation index
% we allocate twice the number of partials, to assure a long rests between
% voice allocations in case of death and birth of partials. This is
% required to to avoid glissandi between differents partial tracks playing
% on same voice.

F = NaN*ones(size(f,1)*2,size(f,2));
M = F;
N = F;
BW = F;

%progressbar(0);

for i = 1:size(f,2),
    %progressbar(i/size(f,2))

    si = find(f(:,i)' >10 & m(:,i)' >0); %nothing lower then 10Hz or zero amplitude
    if isempty(si),
        lsi = 0;
    else
        lsi = length(si);
    end

    if i == 1 & lsi>0,
        F(1:lsi,i) = f(si,i);
        M(1:lsi,i) = m(si,i);
        N(1:lsi,i) = n(si,i);
        BW(1:lsi,i) = bw(si,i);

        valoc(1:lsi) = 1;
        vnext = lsi+1;

    else
        vfree = find(isnan(F(:,i-1))); %find free voices in previous step
        valoc(vfree) = 0;

        for k = 1:lsi,
            Fk = f(si(k),i); %frequency of k-th partial
            Mk = m(si(k),i);
            Nk = n(si(k),i);
            BWk = bw(si(k),i);

            % free voices that are zero amplitude
            %vfree = find(M(:,i-1) == 0 | isnan(M(:,i-1)));

            %find all partials that are less then Aratio different in
            %amplitude
            IM = find(M(:,i-1)>0 & ~isnan(M(:,i-1)));
            dAk = abs(10*log10(M(IM,i-1)/Mk));
            IA = IM(find(dAk < Aratio));

            %among partials that are close in amplitude, pick the one closest in
            %frequency that does not exceed Fmin, Fmax frequency ratio
            %IA = IA(find(~isnan(F(IA,i-1)))); %make sure there was freq. value (precaution)
            if isempty(IA),
                kk = [];
            else
                Fratio = F(IA,i-1)/Fk;
                IF = find(Fratio < Fmax & Fratio > Fmin);
                if ~isempty(IF),
                    [dFmin,kmin] = min(abs(log(Fratio(IF)))); %abs(log()): check both up and down
                    kk = IA(IF(kmin));
                else
                    kk = [];
                end
            end

            % if there was no continuation found, create a new voice with
            % this partial
            % else (if a continuation found)
            %   if no other partial was already assigned to this voice,
            %       proceed to assign the current partial
            %   else (if another partial was already assigned), then
            %       if the current one is closer, switch tracks and put the old partial
            %           as the new voice
            %       otherwise assign new partial to a new voice.

            if isempty(kk), %there was no continuation found 
                % - new partial born at vnext
                F(vnext,i) = Fk;
                M(vnext,i) = Mk;
                N(vnext,i) = Nk;
                BW(vnext,i) = BWk;
                [vnext,valoc] = getvoice(vnext,valoc);
            else %continuation found
                if isnan(F(kk,i)), %no other partial uses this voice
                    %This means that F(kk,i-1) exists but there was no 
                    %previos continuation already assigned to it at this
                    %time
                    F(kk,i) = Fk;
                    M(kk,i) = Mk;
                    N(kk,i) = Nk;
                    BW(kk,i) = BWk;
                    if valoc(kk) == 0,
                        warning('something is wrong with voice allocation ...')
                    end
                else
                    if dFmin < abs(log(F(kk,i-1)/F(kk,i))),
                        %if a frequency was already assigned but the new one is closer
                        %a frequency was already assigned but the new one is
                        %better, then switch them
                        %                 Fratio(IF(kmin))
                        %                 F(kk,i-1)/F(kk,i)
                        %                 abs(log(F(kk,i-1)/Fk))
                        %                 dFmin
                        %                 abs(log(F(kk,i-1)/F(kk,i)))

                        F(vnext,i) = F(kk,i); %new partial born at vnext
                        M(vnext,i) = M(kk,i);
                        N(vnext,i) = N(kk,i);
                        BW(vnext,i) = BW(kk,i);
                        [vnext,valoc] = getvoice(vnext,valoc);
                        F(kk,i) = Fk;
                        M(kk,i) = Mk;
                        N(kk,i) = Nk;
                        BW(kk,i) = BWk;
                        if valoc(kk) == 0,
                            warning('something is wrong with voice allocation ...')
                        end

                    else %the previously assigned continuation is better
                        % then new partial born at vnect
                        F(vnext,i) = Fk;
                        M(vnext,i) = Mk;
                        N(vnext,i) = Nk;
                        BW(vnext,i) = BWk;
                        [vnext,valoc] = getvoice(vnext,valoc);
                    end
                end
            end
        end

        if vnext > length(valoc),
            warning('too many partials')
        end
    end
end

F(find(F==0)) = NaN; %The unassigned tracks are given NaN again (instead of 0)
M(find(F==0)) = NaN;
N(find(F==0)) = NaN;
BW(find(F==0)) = NaN;

% keep = sum(~isnan(F)') >= 2;
% F = F(find(keep),:);
% M = M(find(keep),:);
% N = N(find(keep),:);
% BW = BW(find(keep),:);


function [vnext,valoc] = getvoice(vnext,valoc)
valoc(vnext) = 1;
vfree = find(valoc == 0);
k = min(find(vfree > vnext));
if ~isempty(k),
    vnext = vfree(k);
else
    vnext = vfree(1);
end
if isempty(vnext),
    disp('Gottcha')
end
