function [takenInd_1, takenInd_2] = greedyMatching(controlData_1, controlData_2, ...
    binInd_1, binInd_2, numBins)

n_group1 = numel(controlData_1);
n_group2 = numel(controlData_2);

takenInd_1 = false(n_group1,1);
takenInd_2 = false(n_group2,1);

for i = 1:numBins

    curInd_1 = binInd_1 == i;
    curInd_2 = binInd_2 == i;

    n_group1_curBin = sum(curInd_1);
    n_group2_curBin = sum(curInd_2);

    % If there is an equal number of data points in each group, greedy matching is not possible
    if n_group1_curBin == n_group2_curBin
        continue
    end

    if n_group1_curBin < n_group2_curBin
        ind_small = find(curInd_1);
        ind_big = find(curInd_2);
        curData_small = controlData_1;
        curData_big = controlData_2;
    elseif n_group1_curBin > n_group2_curBin
        ind_small = find(curInd_2);
        ind_big = find(curInd_1);
        curData_small = controlData_2;
        curData_big = controlData_1;
    end

    numPoints = min(n_group1_curBin, n_group2_curBin);

    remaining = true(length(ind_big),1); % the data in the larger group which has not already been chosen
    taken = nan(numPoints,1);
    for j = 1:numPoints % loop through all points in the smaller group
        remainingInd = find(remaining); 
        diffs = abs(curData_small(ind_small(j)) - curData_big(ind_big(remaining))); 
        [~,indMin] = min(diffs); 
        taken(j) = remainingInd(indMin); 
        remaining(taken(j)) = false; 
    end

    if n_group1_curBin < n_group2_curBin
        takenInd_1(ind_small) = true;
        takenInd_2(ind_big(taken)) = true;
    elseif n_group1_curBin > n_group2_curBin
        takenInd_2(ind_small) = true;
        takenInd_1(ind_big(taken)) = true;
    end
    
end


