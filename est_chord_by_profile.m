
function [y,hpcp_corr] = est_chord_by_profile(hpcp,type);
  
  nframe = size(hpcp,2);
  hpcp_trans = circshift(hpcp,-5); % transpose from G to C

  % chord estimation using correlation with key profiles (Krumhansl)
    Cmaj_key_prof = [6.35;2.23;3.48;2.33;4.38;4.09;2.52;5.19;2.39;3.66;2.29;2.88];
    Cmin_key_prof = [6.33;2.68;3.52;5.38;2.60;3.53;2.54;4.75;3.98;2.69;3.34;3.17];

    Cmaj_chord_prof = [6.66;4.71;4.60;4.31;4.64;5.59;4.36;5.33;5.01;4.64;4.73; ...
                       4.67];
    Cmin_chord_prof = [5.30;4.11;3.83;4.14;3.99;4.41;3.92;4.38;4.45;3.69;4.22; ...
                       3.85];

% $$$     Cmaj_bm_prof = [1.83;.1;.45;.33;1.1;.7;.25;1;.33;.85;.2;0];
% $$$     Cmin_bm_prof = [1.6;.2;.25;1.33;.1;.95;0;1;.83;.35;.2;.33]; % bit-mask method
    Cmaj_bm_prof = [1;0;0;0;1;0;0;1;0;0;0;0]; % bit-mask method
    Cmin_bm_prof = [1;0;0;1;0;0;0;1;0;0;0;0];
% $$$     Cmaj_bm_prof = [1;0;0;0;1;0;0;1;0;0;-5;1]; % bit-mask method
% $$$     Cmin_bm_prof = [1;0;0;1;0;0;0;1;0;0;1;-5];
% $$$     Cmaj_bm_prof = [1.75;0;.3333;0;1.95;0;0;2.0833;.2;0;0;.5333]; % bit-mask method
% $$$     Cmin_bm_prof = [1.75;0;.3333;1.75;.2;0;0;2.2833;0;0;.3333;.2];

    maj_prof = [];
    min_prof = [];
    switch type
     case 1, % use key profile
      for i=1:12
        maj_prof = [maj_prof,circshift(Cmaj_key_prof,i-1)];
        min_prof = [min_prof,circshift(Cmin_key_prof,i-1)];
      end
     case 2, % use chord profile
      for i=1:12
        maj_prof = [maj_prof,circshift(Cmaj_chord_prof,i-1)];
        min_prof = [min_prof,circshift(Cmin_chord_prof,i-1)];
      end
     case 3, % use bit mask
      for i=1:12
        maj_prof = [maj_prof,circshift(Cmaj_bm_prof,i-1)];
        min_prof = [min_prof,circshift(Cmin_bm_prof,i-1)];
      end
     otherwise
      error('Wrong type!');
    end
    
    profile = [maj_prof,min_prof]; 

    hpcp_corr = zeros(24,nframe);
    for i=1:nframe
      hpcp_corr(:,i) = corr(hpcp_trans(:,i),profile)'; % correlation
      %hpcp_corr(:,i) = (hpcp_trans(:,i)'*profile)'; % cosine similarity
      %hpcp_corr(:,i) = corr(log10(hpcp_trans(:,i)),log10(profile))';
      chord_est(i) = find(hpcp_corr(:,i)==max(hpcp_corr(:,i)));
    end

    y = chord_est;
    
    
    
