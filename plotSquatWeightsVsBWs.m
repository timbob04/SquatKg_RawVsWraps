function plotSquatWeightsVsBWs(xData, yData, xLim, yLim, ...
    xData_mean, yData_mean, weightClassLimits, ...
    n, scatLims_size, scatLims_n)

xData_lim = max(min(xData,xLim(2)),xLim(1));
yData_lim = max(min(yData,yLim(2)),yLim(1));

scatter(xData_lim, yData_lim, 10, 'k', 'filled', 'MarkerFaceAlpha', 0.1);
hold on

for i = 1:numel(weightClassLimits)
    plot([weightClassLimits(i) weightClassLimits(i)],yLim,'r:')
end

nForBins_lim = max(min(n, scatLims_n(2)), scatLims_n(1));
scatSizes = (nForBins_lim - scatLims_n(1)) ./ diff(scatLims_n) ...
        * diff(scatLims_size) + scatLims_size(1);

scatter(xData_mean, yData_mean, scatSizes, 'r', 'filled', 'MarkerFaceAlpha', 1);
plot(xData_mean, yData_mean,'r','LineWidth',.5)

set(gca,'XLim',xLim, 'Color','none', 'tickdir','out', 'YLim',yLim, ...
    'yTick',yLim(1):100:yLim(2),'fontsize',11)

xDataTemp = [xLim(2) - diff(xLim)*.15 xLim(2) - diff(xLim)*.08];
yDataTemp = yLim(1) + diff(yLim)*.05;
scatter(xDataTemp, [yDataTemp yDataTemp],scatLims_size,'g','filled')