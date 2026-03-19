function [pVals, RBC] = getStats_binnedRawWraps(data_1, data_2, ind_1, ind_2, numBins)


pVals = nan(1, numBins);
RBC = nan(1, numBins);

if exist('ranksum','file') == 0
    return
end

for i = 1:numBins
    % Get current bin's squat weights for Raw and Wraps
    curBinData_1 = data_1(ind_1 == i);
    curBinData_2 = data_2(ind_2 == i);
    % Rank sum test (WRAPS FIRST)
    [pVals(i), ~, stats] = ranksum(curBinData_2, curBinData_1);
    % Rank-biserial correlation (RBC) effect size
    R_wraps = stats.ranksum;    
    n1 = numel(curBinData_2);
    n2 = numel(curBinData_1);
    U_wraps = R_wraps - n1*(n1 + 1)/2;
    RBC(i) = (2*U_wraps)/(n1*n2) - 1;
end