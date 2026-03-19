function [residuals, p_store] = getResiduals(var_test, var_control, ind, numBins, polyOrder)

residuals = nan(numel(var_test), 1);

p_store = cell(numBins,1);
for i = 1:numBins
    
    curBinInd = ind == i;

    xData = var_control(curBinInd);
    yData = var_test(curBinInd);
    
    % Skip bins with too little data
    if sum(curBinInd) < 5
        continue
    end

    % Fit linear model: squat ~ bodyweight
    p = polyfit(xData, yData, polyOrder);
    p_store{i} = p;

    % Predicted squat
    varPred_test = polyval(p, xData);

    % Residuals
    residuals(curBinInd) = yData - varPred_test;
    
end