function plotScatterRaster(xData, yData, saveName, xLim, yLim, yTick, ...
    xTick, figPos, weightClassBins, med_x, med_y, meanSD_x, mean_y, ...
    SD_y, scInc_x, scInc_y)

% This function plots the scatter points as one plot and saves it as a
% raster image, and then plots all the other stuff (axes, any other lines, 
% etc) as a different plot and saves it as a vector image.  This is useful
% when there are a lot of scatter points, and loading them all into
% illustrator as a vector image causes it to slow down.  The raster image
% is made so its boundary fits perfectly inside the rectangle drawn on the
% vector image

xLim_plot = xLim + [-scInc_x scInc_x];
yLim_plot = yLim + [-scInc_y scInc_y];

tickPer = .015;

% Save the scatter portion of the figure as a png
figure('Units','pixels','Position',figPos,'Color','w');
scatter(xData, yData, 10, 'k', 'filled', 'MarkerFaceAlpha', 0.1);
ax = gca;
set(ax, ...
    'XLim', xLim_plot, ...
    'yLim', yLim_plot, ...
    'Clipping', 'off', ...
    'Visible', 'off', ...
    'Units','normalized', ...
    'Position',[0 0 1 1])
drawnow
pause(1)
F = getframe(gcf);
saveName_png = sprintf('%s_%s',saveName,'png.png');
imwrite(F.cdata, saveName_png)

% Save the rest of the figure as a pdf
figure('Position',figPos)
hold on
for i = 2:numel(weightClassBins)-1
    plot([weightClassBins(i) weightClassBins(i)],yLim ,'r:')
end
scatter(med_x, med_y, 20, 'r', 'filled', 'MarkerFaceAlpha', 1);
plot(meanSD_x, mean_y,'m','linewidth',0.5)
plot(meanSD_x, SD_y,'m-o')
ax = gca;
lineW = ax.LineWidth;
set(gca,'XLim',xLim_plot, 'Color','none', 'yLim',yLim_plot, ...
    'XColor','none','clipping','off','YColor','none')
pause(1)
plot(xLim,[ yLim(1) yLim(1)],'k','linewidth',lineW)
tickLen = diff(yLim) * tickPer;
for i = 1:numel(xTick)
    plot([xTick(i) xTick(i)], [yLim(1) yLim(1)-tickLen],'k','linewidth',lineW)
end
plot([xLim(1) xLim(1)],yLim,'k','linewidth',lineW)
tickLen = diff(xLim) * tickPer;
for i = 1:numel(yTick)
    plot([xLim(1)-tickLen xLim(1)], [yTick(i) yTick(i)],'k','linewidth',lineW)
end

plot(xLim_plot,[yLim_plot(2) yLim_plot(2)],'k','linewidth',lineW)
plot(xLim_plot,[yLim_plot(1) yLim_plot(1)],'k','linewidth',lineW)
plot([xLim_plot(2) xLim_plot(2)],yLim_plot,'k','linewidth',lineW)
plot([xLim_plot(1) xLim_plot(1)],yLim_plot,'k','linewidth',lineW)
saveName_pdf = sprintf('%s_%s.pdf',saveName,'pdf');
exportgraphics(gcf, saveName_pdf, 'ContentType','vector', 'Padding',0)

% Now plot and save the entire thing, just for viewing
figure('Position',figPos)
scatter(xData, yData, 10, 'k', 'filled', 'MarkerFaceAlpha', 0.1);
hold on
for i = 2:numel(weightClassBins)-1
    plot([weightClassBins(i) weightClassBins(i)],yLim_plot,'r:')
end
scatter(med_x, med_y, 20, 'r', 'filled', 'MarkerFaceAlpha', 1);
plot(meanSD_x, mean_y,'m','linewidth',0.5)
plot(meanSD_x, SD_y,'m-o')
set(gca,'XLim',xLim_plot, 'Color','none', 'tickdir','out', 'yLim',yLim_plot, ...
    'yTick',yTick,'fontsize',11,'xticklabel','','xtick',xTick,'clipping','off')
saveName_pdf = sprintf('%s_%s',saveName,'all_pdf');
saveFig(saveName_pdf)

