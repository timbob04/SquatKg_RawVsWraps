function [med_raw, med_wraps, medDiff, CIs, pVals_FDR] = ...
    getStatsWithinBWbins(BWbinInd_raw, BWbinInd_wraps, numBins_BW, ...
    dataIn_raw, dataIn_wraps, numIter, enoughN)

dataExists_raw = sum(BWbinInd_raw(:) == 1:numBins_BW) > 0;
dataExists_wraps = sum(BWbinInd_wraps(:) == 1:numBins_BW) > 0;

% Difference between medians
med_raw = nan(numBins_BW,1);
med_raw(dataExists_raw) = accumarray(BWbinInd_raw, dataIn_raw, [], @median);
med_wraps = nan(numBins_BW,1);
med_wraps(dataExists_wraps) = accumarray(BWbinInd_wraps, dataIn_wraps, [], @median);
medDiff = med_wraps - med_raw;

% CIs
med_randSamp_raw = nan(numBins_BW, numIter);
med_randSamp_wraps = nan(numBins_BW, numIter);
for i = 1:numIter
    med_randSamp_raw(dataExists_raw,i) = accumarray(BWbinInd_raw, ...
        dataIn_raw, [], @(dataForCurBin) randomSampleMedian(dataForCurBin));
    med_randSamp_wraps(dataExists_wraps,i) = accumarray(BWbinInd_wraps, ...
        dataIn_wraps, [], @(dataForCurBin) randomSampleMedian(dataForCurBin));
end
med_randSamp_diff = med_randSamp_wraps - med_randSamp_raw;
CIs = prctile(med_randSamp_diff, [2.5 97.5], 2);

% P values
[pVals, ~] = getStats_binnedRawWraps(dataIn_raw, dataIn_wraps, ...
    BWbinInd_raw, BWbinInd_wraps, numBins_BW);
pVals_FDR = nan(1,numel(enoughN));
if exist('mafdr','file') == 0
    return
end
pVals_FDR(enoughN) = mafdr(pVals(enoughN),'BHFDR',true);