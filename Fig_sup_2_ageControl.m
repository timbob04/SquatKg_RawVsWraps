%% Getting residuals figure

curBWbin = 7; % the weight class bin to use

smoothNum = 3;

xData = [ T_raw.Age(:) ; T_wraps.Age(:) ];
xLims = [18 75];

polyNum = 2; % fit data using this degree polynomial

% The x- and y-limits to the area I want to show a close-up of
closeUp_x = [60 65];
closeUp_y = [130 160];

% unadjusted y-data - squat weight
yData = [ T_raw.maxSquat(:) ; T_wraps.maxSquat(:) ];
yLims = [50 350];

% adjusted y-data - squat weight with age regressed out
yData_control_raw = T_raw.residuals_age(:); 
yData_control_wraps = T_wraps.residuals_age(:);

curInd_raw = T_raw.weightClassIndex == curBWbin;
curInd_wraps = T_wraps.weightClassIndex == curBWbin;
curInd = [ curInd_raw(:) ; curInd_wraps(:) ];

n_r = sum(curInd_raw);
n_wr = sum(curInd_wraps);

figure('Position',[2307 78 922 508])

col = [ zeros(n_r,3) ; repmat([1 0 0],n_wr,1)];

% Squat Kg versus strength score plot, for a single BW bin

axes('Position',[ .05 .05 .3 .5])
hold on

xPlot = xData(curInd);
yPlot = yData(curInd);

xPlot_lim = max(min(xPlot,xLims(2)),xLims(1));
yPlot_lim = max(min(yPlot,yLims(2)),yLims(1));

yFit = polyfit(xPlot, yPlot, polyNum );
xData_fit = linspace(xLims(1),xLims(2),100);
yData_fit = polyval(yFit,xData_fit);

scatter(xPlot_lim, yPlot_lim, 15, col, 'filled', 'MarkerFaceAlpha', 0.5)
plot(xData_fit, yData_fit, 'g','LineWidth',3)
set(gca,'XLim',xLims,'YLim',yLims,'tickdir','out','Color','none')
xFill = [ closeUp_x(1) closeUp_x(2) closeUp_x(2) closeUp_x(1) closeUp_x(1) ];
yFill = [ closeUp_y(1) closeUp_y(1) closeUp_y(2) closeUp_y(2) closeUp_y(1) ];
fill(xFill,yFill,'b','FaceAlpha',0)
pbaspect([1 1 1])

% Close-up to show residuals

axes('Position',[ .3 .6 .13 .18])
hold on

ind_closeUp = find(xPlot > closeUp_x(1) & xPlot < closeUp_x(2) & ...
    yPlot > closeUp_y(1) & yPlot < closeUp_y(2)); % Index to data to plot

% Plot line
yData_fit = polyval(yFit,closeUp_x);
plot(closeUp_x, yData_fit, 'g','LineWidth',3)
% Plot residuals
residuals_closeUp = polyval(yFit,xPlot(ind_closeUp));
for i = 1:numel(ind_closeUp)
    plot([xPlot(ind_closeUp(i)) xPlot(ind_closeUp(i))],...
        [yPlot(ind_closeUp(i)) residuals_closeUp(i)] , 'b' );
end
% Plot data points
scatter(xPlot_lim(ind_closeUp), yPlot_lim(ind_closeUp), 60, ...
    col(ind_closeUp,:), 'filled', 'MarkerFaceAlpha', 0.5)
set(gca,'XLim',closeUp_x,'YLim',closeUp_y,'tickdir','out',...
    'XLim',closeUp_x, 'YLim',closeUp_y, 'XTick','', ...
    'YTick','','Color','none')
pbaspect([1 1 1])

% Squat Kg vs strength score with strength score regressed out of squat Kg

axes('Position',[ .45 .05 .3 .5])
hold on
% Get residuals and fit
yData = [ yData_control_raw(:) ; yData_control_wraps(:) ];
yLims = [-100 100];
yPlot = yData(curInd);
yFit = polyfit(xPlot, yPlot, polyNum);
yData_fit = polyval(yFit,xData_fit);
% plot data
yPlot_lim = max(min(yPlot,yLims(2)),yLims(1));
scatter(xPlot_lim, yPlot_lim, 15, col, 'filled', 'MarkerFaceAlpha', 0.5)
plot(xData_fit, yData_fit, 'g','LineWidth',3)
pbaspect([1 1 1])
set(gca,'XLim',xLims,'YLim',yLims,'tickdir','out','Color','none')

% Side histogram

axes('Position',[ .76 .05 .05 .5])
hold on

h_lim = yLims(2);
binSize = 10;
bins = -h_lim-binSize/2:binSize:h_lim+binSize/2;
numBins = numel(bins)-1;

binCenters = (bins(1:end-1) + bins(2:end)) / 2;

% Get raw data histogram
curData = yData_control_raw(curInd_raw);
med_raw = median(curData);
curData_lim = max(min(curData,h_lim),-h_lim);
h = histcounts(curData_lim,bins);
h_raw_per = (h / sum(h)) * 100;
h_raw_per_sm = smooth(h_raw_per,smoothNum);
% Get wraps data histogram
curData = yData_control_wraps(curInd_wraps);
med_wraps = median(curData);
curData_lim = max(min(curData,h_lim),-h_lim);
h = histcounts(curData_lim,bins);
h_wraps_per = (h / sum(h)) * 100;
h_wraps_per_sm = smooth(h_wraps_per,smoothNum);

plot(h_raw_per_sm,binCenters,'k','linewidth',2)
plot(h_wraps_per_sm,binCenters,'r','linewidth',2)
XLIM = get(gca,'XLim');
plot(XLIM,[med_raw med_raw],'k:','linewidth',1.5)
plot(XLIM,[med_wraps med_wraps],'r:','linewidth',1.5)
set(gca,'YColor','none','Color','none','box','off','clipping','off','tickdir','out')

saveName = fullfile(saveFigFol, sprintf('S2_getResiduals_%s',sexToAnalyze));
saveFig(saveName);

%% Control - residuals - histograms of residuals for all BW bin

smoothNum = 3;

% Bins
binStart = 100;
binSize = 10;
bins = -binStart-(binSize/2):binSize:binStart+(binSize/2);

% Data for plot
curData_raw = T_raw.residuals_age;
curData_wraps = T_wraps.residuals_age;
curInd_raw = T_raw.weightClassIndex;
curInd_wraps = T_wraps.weightClassIndex;

x_start = 2; % starting point on the x-axis for the first distribution
x_spacer = 17; % how much to shift the next distribution in line, along the x-axis

makeMutliHistogramPlot(bins, curData_raw, curData_wraps, ...
    curInd_raw, curInd_wraps, smoothNum, x_start, x_spacer, numBins_BW, ...
    enoughN, binStart)

ylabel('Squat Kg')

saveName = fullfile(saveFigFol, sprintf('S2_histograms_SquatKg_res_age_%s',sexToAnalyze));
saveFig(saveName);

%% Wraps minus Raw

figure
plotMedDiff(binCenters_BWcat(enoughN), medDiff_squat_reg_age(enoughN), ...
    CIs_squat_reg_age(enoughN,:), scatSizes(enoughN), xLim_BW, yLim_squat, ...
    weightClassBins, scatLims_size)
scatter(binCenters_BWcat(enoughN), medDiff_squat(enoughN), 10, 'r', 'filled', 'MarkerFaceAlpha', 1);

saveName = fullfile(saveFigFol, sprintf('S2_wrapsMinusRaw_squatKg_res_age_%s',sexToAnalyze));
saveFig(saveName);

%% Adjust vs unadjust

YLims = [0 150];
XLims = [50 130];

xData = weightClassBins(enoughN);
yData = ( medDiff_squat_reg_age(enoughN) ./ medDiff_squat(enoughN)) * 100;
yData_lim = max(min(yData, YLims(2)),YLims(1));

figure
hold on
scatter(xData, yData_lim,150,'k','filled','MarkerFaceAlpha',0.5)
set(gca,'XLim',XLims,'YLim',YLims,'fontsize',17,'linewidth',1,...
    'tickdir','out','Color','none','xtick',xData)
plot(XLims,[0 0],'k:')

saveName = fullfile(saveFigFol, sprintf('S2_adjustVsUnadjust_squatKg_age_%s',sexToAnalyze));
saveFig(saveName);
