function [xBins_centers, meanResp, SDresp, zScoredData, meanResp_zScore] = ...
    getBinnedZscore(xData, yData, xLim, xBins)

% Binned x data
xBins_centers = ( xBins(1:end-1) + xBins(2:end) ) / 2;
numBins = numel(xBins_centers);
dataTake = xData > xLim(1) & xData < xLim(2);
curBinInd = discretize(xData(dataTake), xBins, 'IncludedEdge', 'right');

% Bins that contain values
containsData = sum(curBinInd(:) == 1:numBins) > 0;

% Mean for each x-bin
meanResp = nan(numBins,1);
meanResp(containsData) = accumarray(curBinInd, yData(dataTake), [], @mean);

% SD for each x-bin
SDresp = nan(numBins,1);
SDresp(containsData) = accumarray(curBinInd, yData(dataTake), [], @std);

% Get the z-score for each data point
xData_lim = max(min(xData,xLim(2)),xLim(1)); % Bind all x-values within the limits
curBinInd = discretize(xData_lim, xBins, 'IncludedEdge', 'right');
zScoredData = nan(numel(yData),1);
for i = 1:numBins
    curInd = curBinInd == i;
    curYdata = yData(curInd);
    zScoredData(curInd) = ( curYdata - meanResp(i) ) / SDresp(i);
end

meanResp_zScore = nan(numBins,1);
meanResp_zScore(containsData) = accumarray(curBinInd, zScoredData, [], @mean);