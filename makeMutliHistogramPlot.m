function makeMutliHistogramPlot(bins, data_1, data_2, ind_1, ind_2, ...
    smoothNum, x_start, x_spacer, numGroups, enoughN, binStart)

binCenters = ( bins(1:end-1) + bins(2:end) ) / 2;
numBins = numel(binCenters);

data_1_lim = max(min(data_1,bins(end)),bins(1));
data_2_lim = max(min(data_2,bins(end)),bins(1));

exist_1 = sum(ind_1(:) == 1:numGroups) > 0; 
exist_2 = sum(ind_2(:) == 1:numGroups) > 0; 

% Get histograms
curFunc = @(x) binData(x, bins);
h_1 = nan(numGroups,numBins);
h_1(exist_1,:) = splitapply(curFunc, data_1_lim, ind_1);
h_2 = nan(numGroups,numBins);
h_2(exist_2,:) = splitapply(curFunc, data_2_lim, ind_2);
% Convert counts to percentages
h_1_per = (h_1 ./ sum(h_1,2)) * 100;
h_2_per = (h_2 ./ sum(h_2,2)) * 100;

% Get medians
med_1 = nan(numGroups,1);
med_1(exist_1) = splitapply(@median, data_1, ind_1);
med_2 = nan(numGroups,1);
med_2(exist_2) = splitapply(@median, data_2, ind_2);

figure('Position',[1968 688 771 158])
hold on

k = x_start;
for i = 1:numGroups
    if ~enoughN(i)
        k = k+x_spacer;
        continue
    end
    
    % Plot distributions
    dataSmooth_raw = smooth(h_1_per(i,:)+k, smoothNum);
    plot(dataSmooth_raw, binCenters,'k','linewidth',1.5);
    dataSmooth_wraps = smooth(h_2_per(i,:)+k, smoothNum);
    plot(dataSmooth_wraps, binCenters,'r','linewidth',1.5);

    minPoint = min([ dataSmooth_raw(:) ; dataSmooth_wraps(:) ] );
    maxPoint = max([ dataSmooth_raw(:) ; dataSmooth_wraps(:) ] );

    % Plot medians
    plot([minPoint maxPoint], [med_1(i) med_1(i)], 'k:', 'linewidth', 1)
    plot([minPoint maxPoint], [med_2(i) med_2(i)], 'r:', 'linewidth', 1)

    k = k+x_spacer;

end

endPlot = k+x_spacer;

YLIM = [ -binStart binStart ];

plot([endPlot-10 endPlot],[YLIM(1) YLIM(1)],'k')
set(gca,'YLim',YLIM,'Color','none','ytick',[-binStart 0 binStart], ...
    'XLim', [0 endPlot], 'XColor', 'none', 'tickdir' , 'out' )