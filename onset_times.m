function [onsets_seconds, attack_durations] = onset_times(audio_signal, sample_rate)
% Return times in seconds of the location of onsets in the audio file.
  threshold = 1.5;

  [wodf, odf_sr, subband_odfs, ODF_start_seconds] = odf_of_signal(audio_signal, sample_rate);
  % Find the relative difference of the wide-band onset detection function. 
  % This identifies rapid attack slopes.
  wodf_diff = diff(wodf);
  % The parabolic maxima identify the perceptual-centers of the onsets.
  allPeaks = peaks(wodf_diff);

  bigPeaks = (wodf_diff .* allPeaks) > (std(wodf_diff) * threshold);
  peak_times = find(bigPeaks);

  % We've found the peaks of the relative difference, however, what we ultimately want are the
  % attack onset times preceding these. Therefore the compensation descends from the peaks to
  % the nearest preceding troughs.
  onset_times = find_onset_attacks(wodf, peak_times, odf_sr);
  attack_durations = (peak_times - onset_times) ./ odf_sr;

  % figure()
  % plot(wodf, "1", onset_times, wodf(onset_times), "2^")
  % figure()
  % plot(odf_downsampled_signal * 4, "1", wodf, "2")

  % Compensate for the ODF 
  onsets_seconds = (onset_times ./ odf_sr) - ODF_start_seconds;
end
