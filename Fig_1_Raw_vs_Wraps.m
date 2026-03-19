%% Squat weight versus bodyweight - for Raw and Wraps

scatLims_size_cur = [4 80];
scatLims_n_cur = [20 500];

yLim = [50 350];

% Raw
figure
plotSquatWeightsVsBWs(T_raw.BW, T_raw.maxSquat, xLim_BW, yLim, ...
    binCenters_BWcat, med_raw, weightClassBins, ...
    n_BWbins_raw, scatLims_size_cur, scatLims_n_cur)

saveName = fullfile(saveFigFol, sprintf('Squat_vs_BW_raw_%s',sexToAnalyze));
saveFig(saveName);

% Wraps
figure
plotSquatWeightsVsBWs(T_wraps.BW, T_wraps.maxSquat, xLim_BW, yLim, ...
    binCenters_BWcat, med_wraps, weightClassBins, ...
    n_BWbins_wraps, scatLims_size_cur, scatLims_n_cur)

saveName = fullfile(saveFigFol, sprintf('Squat_vs_BW_wraps_%s',sexToAnalyze));
saveFig(saveName);

%% Histograms of squat weights relative to the Raw medians

% Bins
binStart = 100;
binSize = 10;
bins_stSc = -binStart-(binSize/2):binSize:binStart+(binSize/2);

% Data for plot
curData_raw = T_raw.maxSquat;
curData_wraps = T_wraps.maxSquat;
curInd_raw = T_raw.weightClassIndex;
curInd_wraps = T_wraps.weightClassIndex;

% Get the Raw and Wraps squat Kg data relative to the Raw medians
diffs = repmat(curData_raw,1,numBins_BW) - med_raw(:)';
ind = sub2ind(size(diffs),1:height(diffs),curInd_raw');
squatRelMed_raw = diffs(ind);
diffs = repmat(curData_wraps,1,numBins_BW) - med_raw(:)';
ind = sub2ind(size(diffs),1:height(diffs),curInd_wraps');
squatRelMed_wraps = diffs(ind);

x_start = 2; % starting point on the x-axis for the first distribution
x_spacer = 16; % how much to shift the next distribution in line, along the x-axis

makeMutliHistogramPlot(bins_stSc, squatRelMed_raw(:), squatRelMed_wraps(:), ...
    curInd_raw, curInd_wraps, 3, x_start, x_spacer, numBins_BW, ...
    enoughN, binStart)

ylabel({'Squat Kg (relative';'to Raw medians)'})

saveName = fullfile(saveFigFol, sprintf('histograms_squatKg_%s',sexToAnalyze));
saveFig(saveName);

%% Difference in medians

% Squat weights
figure
plotMedDiff(binCenters_BWcat(enoughN), medDiff_squat(enoughN), ...
    CIs_squat(enoughN,:), scatSizes(enoughN), xLim_BW, yLim_squat, ...
    weightClassBins, scatLims_size)
saveName = fullfile(saveFigFol, sprintf('WrapsMinusRaw_squat_%s',sexToAnalyze));
saveFig(saveName);