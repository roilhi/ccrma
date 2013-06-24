function [distances] = getDistanceMatrix(featuresA, featuresB);
    distances = zeros(size(featuresA, 1), size(featuresB, 1));
for i = 1:size(featuresA, 1)
    fA = featuresA(i, :);
    for j = 1:size(featuresB, 1)
      fB = featuresB(j, :);
      distances(i,j) = dist2(fA, fB);
    end
end
