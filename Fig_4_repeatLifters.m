%% Mean median difference plot from all iterations

minN_oneMeet = 100;

enoughN_oneMeet = n_oneMeet >= minN_oneMeet;

scatLims_n_oneMeet = [minN_oneMeet 400];

scatSizes_oneMeet = (n_oneMeet - scatLims_n_oneMeet(1)) ./ diff(scatLims_n_oneMeet) ...
        * diff(scatLims_size) + scatLims_size(1);

figure
plotMedDiff(binCenters_BWcat(enoughN_oneMeet), medDiff_oneMeet(enoughN_oneMeet), ...
    CIs_squat_oneMeet(enoughN_oneMeet,:), scatSizes_oneMeet(enoughN_oneMeet), ...
    xLim_BW, yLim_squat, weightClassBins, scatLims_size)
scatter(binCenters_BWcat(enoughN), medDiff_squat(enoughN), 10, 'r', 'filled', 'MarkerFaceAlpha', 1);

saveName = fullfile(saveFigFol, sprintf('F4_wrapsMinusRaw_squatKg_oneMeet_%s',sexToAnalyze));
saveFig(saveName);