%% Raw-Wraps difference - strength score matched (nearest neighbor matching)

figure
plotMedDiff(binCenters_BWcat(enoughN), medDiff_squat_match_stSc(enoughN), ...
    CIs_squat_match_stSc(enoughN,:), scatSizes(enoughN), xLim_BW, yLim_squat, ...
    weightClassBins, scatLims_size)
scatter(binCenters_BWcat(enoughN), medDiff_squat(enoughN), 10, 'r', 'filled', 'MarkerFaceAlpha', 1);

saveName = fullfile(saveFigFol, sprintf('S1_WrapsMinusRaw_squatKg_match_StSc_%s',sexToAnalyze));
saveFig(saveName);

%% Matched versus unmatched

YLims = [0 150];
XLims = [50 130];

xData = weightClassBins(enoughN);
yData = ( medDiff_squat_match_stSc(enoughN) ./ medDiff_squat(enoughN)) * 100;
yData_lim = max(min(yData, YLims(2)),YLims(1));

figure
hold on
scatter(xData, yData_lim,150,'k','filled','MarkerFaceAlpha',0.5)
set(gca,'XLim',XLims,'YLim',YLims,'fontsize',17,'linewidth',1,...
    'tickdir','out','Color','none')
plot(XLims,[0 0],'k:')

saveName = fullfile(saveFigFol, sprintf('S1_matchVsUnmatch_squatKg_match_StSc_%s',sexToAnalyze));
saveFig(saveName);
