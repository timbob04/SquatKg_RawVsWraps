function plotMedDiff(xData, yData, CIdata, scatSizes, xLim, yLim, weightClassLimits, scatLims_size)

hold on

plot(xData, yData,'Color',[0 0 0 .15],'LineWidth',1)

for i = 1:numel(xData)
    curPct = CIdata(i,:);
    plot([xData(i), xData(i)], curPct,'m','LineWidth',0.5) 
end

plot(xLim,[0 0],'k:','linewidth',0.5)

scatter(xData, yData, scatSizes, 'k', 'filled', 'MarkerFaceAlpha', 1);

for i = 1:numel(weightClassLimits)
    plot([weightClassLimits(i) weightClassLimits(i)],yLim,'r:')
end

set(gca,'XLim',xLim,'yLim',yLim,'Color','none','tickdir','out','clipping','off')

xDataTemp = [xLim(2) - diff(xLim)*.15 xLim(2) - diff(xLim)*.08];
yDataTemp = yLim(1) + diff(yLim)*.05;
scatter(xDataTemp, [yDataTemp yDataTemp],scatLims_size,'g','filled')