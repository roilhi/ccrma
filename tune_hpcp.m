
function y = tune_hpcp_hmm(hpcp,tuning_center);
  
  nframe = size(hpcp,2);
  hpcp_tuned = zeros(12,nframe);
  hpcpn_tuned = zeros(12,nframe);
  if 1 <= tuning_center < 2
    for i=1:nframe
      temp0 = hpcp(:,i);
      temp1 = [hpcp(2:end,i);0];
      temp2 = [hpcp(3:end,i);0;0];
      temp_sum = temp0+temp1+temp2;
      hpcp_tuned(:,i) = downsample(temp_sum,3);
    end
  elseif 0 <= tuning_center < 1
    for i=1:nframe
      hpcp_temp = [hpcp(end,i);hpcp(1:end-1,i)];
      temp0 = hpcp_temp;
      temp1 = [hpcp_temp;0];
      temp2 = [hpcp_temp;0;0];
      temp_sum = temp0+temp1+temp2;
      hpcp_tuned(:,i) = downsample(temp_sum,3);
    end
  elseif 2 <= tuning_center < 3
    for i=1:nframe
      hpcp_temp = [hpcp(2:end,i);hpcp(1,i)];
      temp0 = hpcp_temp;
      temp1 = [hpcp_temp;0];
      temp2 = [hpcp_temp;0;0];
      temp_sum = temp0+temp1+temp2;
      hpcp_tuned(:,i) = downsample(temp_sum,3);
    end
  end

  y = hpcp_tuned;
