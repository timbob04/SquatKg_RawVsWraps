function out = assignMeetCountsByDate(idx, dates, takeYN)

% Initialize vector to store meet count
out = nan(numel(idx),1);
% Logical index indicating which meets to take (to get meet counts) from the current lifter, using takeYN
datesToSort_ind = takeYN(idx);
% All dates for the current lifter's meets
curDates = dates(idx);
% The dates which pass the filter
datesToSort = curDates(datesToSort_ind);
% Find the date order (meet count) for current lifter, for all lifts passing the filter
[~, order] = sort(datesToSort); 
meetCount = nan(size(datesToSort));
meetCount(order) = 1:numel(datesToSort);
% For the lifts passing the filter, add these meet counts
out(datesToSort_ind) = meetCount;





