clear all; close all; clc

%% Input variables

saveFol = '/Users/timothyolsen/Documents/Projects/LiftingStats/Matlab/Figures';

minN = 150; % only plot weight classes with at least this many data points for both Raw and Wraps

sexToAnalyze = 'M';

yLim_squat = [-6 35]; % y-axis limits for the difference in median plots

% n and scatter size variables for controlling the size of the dots in the 'difference in medians' plots
scatLims_size = [30 110];
scatLims_n = [minN 500];

% Weight classes (upper bounds), according to federation/s
weightClassBins = [0 52 56 60 67.5 75 82.5 90 100 110 125 140 1000]; 

% X-axis limits for bodyweight plotting
xLim_BW = [50 160]; 

%% Set paths and load data

fprintf('\nLoading data...')

% Get the path for the data to load - different for loading locally or via Matlab-online
fileName = 'openpowerlifting-2025-08-02-259a9626.csv';
if isfolder('/MATLAB Drive')
    basePath = '/MATLAB Drive';
else
    basePath = fullfile(getenv('HOME'), 'MATLAB-Drive');
end
dataPath = fullfile(basePath,'Data',fileName);

% Set the variable types for variables not loading correctly (with incorrect types)
opts = detectImportOptions(dataPath);
opts = setvartype(opts,{'Tested','Place','Name','Sex','Event','Equipment'}, 'string');
opts = setvartype(opts,{'Date'}, 'datetime');
opts = setvartype(opts,{'Squat4Kg','Bench4Kg','Deadlift1Kg','Deadlift2Kg',...
    'Deadlift3Kg','Deadlift4Kg','Age','BodyweightKg'}, 'double');

% Load data and make into table
data = readtable(dataPath,opts);

% Go to the folder with all the required functions for the following code
cd(fullfile(basePath,'Matlab'));

% Save figure folder
saveFigFol = fullfile(basePath,'Figures');

fprintf('complete')

%% Filters

fprintf('\nCreating filters...')

validPlace = ~isnan(str2double(data.Place));

sanctioned = strcmp(data.Sanctioned,'Yes');

tested = strcmp(data.Tested,'Yes');

eventWithSquat = ismember(data.Event,{'S','SBD','SD','SB'});

federation = ismember(data.ParentFederation, {'IPL', 'WRPF'});

timeline = data.Date > datetime('1900-01-01', 'InputFormat', 'uuuu-MM-dd');

SBD = strcmp(data.Event,'SBD');

ageWithin = data.Age >= 18;

curSex = ismember(data.Sex, sexToAnalyze); 

weightGood = ~isnan(data.BodyweightKg);

successfulSquat = data.Squat1Kg > 0 | data.Squat2Kg > 0 | data.Squat3Kg > 0 | data.Squat4Kg > 0;
successfulBench = data.Bench1Kg > 0 | data.Bench2Kg > 0 | data.Bench3Kg > 0 | data.Bench4Kg > 0;
successfulDeadlift = data.Deadlift1Kg > 0 | data.Deadlift2Kg > 0 | data.Deadlift3Kg > 0 | data.Deadlift4Kg > 0;

successfulSBD = SBD & successfulSquat & successfulBench & successfulDeadlift;

% Find cases where entries are duplicated, using instances where the Name
% and lift data is the same, but something else (State, etc) is different 
subset = data(:, {'Name','Squat1Kg','Squat2Kg','Squat3Kg',...
                       'Bench1Kg','Bench2Kg','Bench3Kg',...
                       'Deadlift1Kg','Deadlift2Kg','Deadlift3Kg'});
[~,~,dupID] = unique(subset,'rows');
counts = histcounts(dupID, 1:max(dupID)+1);
isDuplicate = counts(dupID) > 1;

% The main filter - only analyzing this data
filter_main = validPlace(:) & sanctioned(:) & tested(:) & weightGood(:) & ...
    federation(:) & ageWithin(:) & curSex(:) & ~isDuplicate(:) & ...
    timeline(:) & successfulSBD(:);

filter_raw = strcmp(data.Equipment,'Raw');
filter_wraps = strcmp(data.Equipment,'Wraps');

fprintf('complete.  Data being processed consists of: ')

earliestLift = min(data.Date(filter_main));

fprintf('\nn raw: %d, n wraps: %d, earliest meet: %s', ...
    sum(filter_main & filter_raw), sum(filter_main & filter_wraps) , ...
    datestr(earliestLift));

%% Max lift data

maxSquat = max([data.Squat1Kg data.Squat2Kg data.Squat3Kg data.Squat4Kg],[],2);
maxBench = max([data.Bench1Kg data.Bench2Kg data.Bench3Kg data.Bench4Kg],[],2);
maxDeadlift = max([data.Deadlift1Kg data.Deadlift2Kg data.Deadlift3Kg data.Deadlift4Kg],[],2);

%% Per-person ID

[~, ~, uniquePersonID] = unique(data.Name, 'stable'); 

%% Meet counts per person (where they squatted)

fprintf('\nGetting meet count stats...')

% Row indices for each person, grouped by person (1st to last unique person)
rowIdx = accumarray(uniquePersonID, (1:numel(uniquePersonID))', [], @(idx){idx}); % return the row index of each unique persons entry
rowIdx = cat(1,rowIdx{:});

% Squat experience (meet count with squat)
filter_meetCount = eventWithSquat(:) & ~isDuplicate(:); % If an event had a squat, this counts to a person's meet count (1 to the total number of meets they have participated in)
meetCountsForEachPerson = accumarray( uniquePersonID, (1:numel(uniquePersonID))' , ...
    [] , @(idx){ assignMeetCountsByDate(idx, data.Date, filter_meetCount) } ); % meet counts (1 to the number of meets) for each unique person, assigned by date of meet
meetCount = reorganizeAfterAccumarray(meetCountsForEachPerson, rowIdx);

fprintf('complete')

%% Put main analysis/plotting data into a table

filter_cur_raw = filter_main & filter_raw;
filter_cur_wraps = filter_main & filter_wraps;

curInd = filter_cur_raw;
T_raw = table(maxSquat(curInd), maxDeadlift(curInd), maxBench(curInd), ...
    data.Age(curInd), meetCount(curInd), data.BodyweightKg(curInd), ...
    uniquePersonID(curInd), 'VariableNames',...
    {'maxSquat','maxDeadlift','maxBench','Age','meetCount','BW','personID'});
curInd = filter_cur_wraps;
T_wraps = table(maxSquat(curInd), maxDeadlift(curInd), maxBench(curInd), ...
    data.Age(curInd), meetCount(curInd), data.BodyweightKg(curInd), ...
    uniquePersonID(curInd), 'VariableNames',...
    {'maxSquat','maxDeadlift','maxBench','Age','meetCount','BW','personID'});

n_raw = height(T_raw);
n_wraps = height(T_wraps);

%% Bodyweight (BW) bin data

numBins_BW = numel(weightClassBins)-1;
binCenters_BWcat = (weightClassBins(1:end-1)+weightClassBins(2:end)) / 2;
binCenters_BWcat(1) = 51; binCenters_BWcat(end) = 150;

% Determine the weight class for each data point (lifter at a meet)
binIdx_raw = discretize(T_raw.BW, weightClassBins, 'IncludedEdge', 'right');
binIdx_wraps = discretize(T_wraps.BW, weightClassBins, 'IncludedEdge', 'right');
T_raw.weightClassIndex = binIdx_raw;
T_wraps.weightClassIndex = binIdx_wraps;

n_BWbins_raw = sum( binIdx_raw(:) == 1:numBins_BW );
n_BWbins_wraps = sum( binIdx_wraps(:) == 1:numBins_BW );

% Determine which weight classes contain enough data points for analysis/plotting
n_BWbins_min = min(n_BWbins_raw, n_BWbins_wraps);
enoughN = n_BWbins_min > minN;
n_plottedBWs = sum(enoughN);

nonEmptyBWbins_raw = sum(binIdx_raw(:) == 1:numBins_BW) > 0;
nonEmptyBWbins_wraps = sum(binIdx_wraps(:) == 1:numBins_BW) > 0;

% Scatter point sizes for difference in medians plots
nForBins_lim = min(n_BWbins_min, scatLims_n(2));
scatSizes = (nForBins_lim - scatLims_n(1)) ./ diff(scatLims_n) ...
        * diff(scatLims_size) + scatLims_size(1);

%% Strength score

maxDeadlift_all = [T_raw.maxDeadlift ; T_wraps.maxDeadlift];
maxBench_all = [T_raw.maxBench ; T_wraps.maxBench];

% x-axis binning variables - BW
binSize = 2.5;
xData = [T_raw.BW ; T_wraps.BW];
xBins_stSc = xLim_BW(1):binSize:xLim_BW(2);

% Get deadlift z-scores
[xBins_centers, meanResp_deadlift, SDresp_deadlift, zScoredData_deadlift, ...
    meanResp_zScore_deadlift] = getBinnedZscore(xData, maxDeadlift_all, ...
    xLim_BW, xBins_stSc);

% Get bench z-scores
[~, meanResp_bench, SDresp_bench, zScoredData_bench, meanResp_zScore_bench] ...
    = getBinnedZscore(xData, maxBench_all, xLim_BW, xBins_stSc);

% The strength score is the mean of the z-scored deadlift and bench press
strengthScore_all = mean([zScoredData_deadlift(:) zScoredData_bench(:)], 2);
T_raw.strengthScore = strengthScore_all(1:n_raw);
T_wraps.strengthScore = strengthScore_all(n_raw+1:end);

%% Resisuals - squat Kg with a control variable regressed out

var_test = [ T_raw.maxSquat ; T_wraps.maxSquat ];
BWind = [ T_raw.weightClassIndex ; T_wraps.weightClassIndex ]; % body weight binning indices

% Squat Kg with Strength score regressed out
var_control = [ T_raw.strengthScore ; T_wraps.strengthScore ];
[residuals, ~] = getResiduals(var_test, var_control, BWind, numBins_BW, 1);
T_raw.residuals_strengthScore = residuals(1:n_raw);
T_wraps.residuals_strengthScore = residuals(n_raw+1:end);

% Squat Kg with BW regressed out
var_control = [ T_raw.BW ; T_wraps.BW ]; % variable to regress out
[residuals, ~] = getResiduals(var_test, var_control, BWind, numBins_BW, 1);
T_raw.residuals_BW = residuals(1:n_raw);
T_wraps.residuals_BW = residuals(n_raw+1:end);

% Squat Kg with Age score regressed out
var_control = [ T_raw.Age ; T_wraps.Age ];
[residuals, ~] = getResiduals(var_test, var_control, BWind, numBins_BW, 2);
T_raw.residuals_age = residuals(1:n_raw);
T_wraps.residuals_age = residuals(n_raw+1:end);

%% Greedy matching

% Find data matched for strength score, within BW bins
[takenInd_1, takenInd_2] = ...
    greedyMatching(T_raw.strengthScore, T_wraps.strengthScore, ...
    T_raw.weightClassIndex, T_wraps.weightClassIndex, numBins_BW);
% Store results
T_raw.matchedInd_strength = takenInd_1;
T_wraps.matchedInd_strength = takenInd_2;

%% Meet count stats

bins_MC = [0.5 1.5 5.5 inf]; % Meet count bins (experience levels: low, medium, high)

numBins_MC = numel(bins_MC)-1;

% Get bin index for each meet count
binInd_MC_raw = discretize(T_raw.meetCount, bins_MC);
binInd_MC_wraps = discretize(T_wraps.meetCount, bins_MC);

% Count the meet count within each meet count and bodyweight bin
count_MC_BW_raw = cell(numBins_BW,1);
count_MC_BW_raw(nonEmptyBWbins_raw) = accumarray(T_raw.weightClassIndex, ...
    T_raw.meetCount, [], @(dataIn){ binData(dataIn, bins_MC) });
count_MC_BW_wraps = cell(numBins_BW,1);
count_MC_BW_wraps(nonEmptyBWbins_wraps) = accumarray(T_wraps.weightClassIndex, ...
    T_wraps.meetCount, [], @(dataIn){ binData(dataIn, bins_MC) });
% Convert counts to percentages
func = @(x) (x/sum(x))*100;
per_MC_BW_raw = cellfun(func, count_MC_BW_raw, 'UniformOutput', false);
per_MC_BW_wraps = cellfun(func, count_MC_BW_wraps, 'UniformOutput', false);

% Indices to data matched for meet count, using random sampling of the
% larger group, for 1000 iterations
numIter_MC = 1000;
MC_randSamp_raw = false(n_raw, numIter_MC);
MC_randSamp_wraps = false(n_wraps, numIter_MC);
for curIter = 1:numIter_MC
    for curBW = 1:numBins_BW
        for curMeetBin = 1:numBins_MC
            curInd_raw = find(T_raw.weightClassIndex == curBW & binInd_MC_raw == curMeetBin);
            curInd_wraps = find(T_wraps.weightClassIndex == curBW & binInd_MC_wraps == curMeetBin);
            n_cur_raw = numel(curInd_raw);
            n_cur_wraps = numel(curInd_wraps);
            n_take = min(n_cur_raw, n_cur_wraps);
            randSamp_raw = randperm(n_cur_raw, n_take);
            randSamp_wraps = randperm(n_cur_wraps, n_take);
            MC_randSamp_raw(curInd_raw(randSamp_raw), curIter) = true;
            MC_randSamp_wraps(curInd_wraps(randSamp_wraps), curIter) = true;
        end
    end
end

%% Stats for Raw vs Wraps, within BW bins

fprintf('\nGetting Raw vs Wraps stats...')

% Squat weight
[med_raw, med_wraps, medDiff_squat, CIs_squat, pVals_squat] = ...
    getStatsWithinBWbins(binIdx_raw, binIdx_wraps, numBins_BW, ...
    T_raw.maxSquat, T_wraps.maxSquat, 1000, enoughN);
% Body weight
[~, ~, medDiff_BW, CIs_BW, ~] = getStatsWithinBWbins(binIdx_raw, ...
    binIdx_wraps, numBins_BW, T_raw.BW, T_wraps.BW, 1000, enoughN);
% Strength score
[med_stSt_raw, med_stSt_wraps, medDiff_stSc, CIs_stSc, ~] = ...
    getStatsWithinBWbins(binIdx_raw, binIdx_wraps, numBins_BW, ...
    T_raw.strengthScore, T_wraps.strengthScore, 1000, enoughN);
% Squat weight - body weights regressed out
[~, ~, medDiff_squat_reg_BW, CIs_squat_reg_BW, ~] = ...
    getStatsWithinBWbins(binIdx_raw, binIdx_wraps, numBins_BW, ...
    T_raw.residuals_BW, T_wraps.residuals_BW, 1000, enoughN);
% Squat weight - strength scores regressed out
[~, ~, medDiff_squat_reg_stSc, CIs_squat_reg_stSc, ~] = ...
    getStatsWithinBWbins(binIdx_raw, binIdx_wraps, numBins_BW, ...
    T_raw.residuals_strengthScore, T_wraps.residuals_strengthScore, 1000, enoughN);
% Squat weight - strength score matched
[~, ~, medDiff_squat_match_stSc, CIs_squat_match_stSc, ~] = ...
    getStatsWithinBWbins(binIdx_raw(T_raw.matchedInd_strength), ...
    binIdx_wraps(T_wraps.matchedInd_strength), numBins_BW, ...
    T_raw.maxSquat(T_raw.matchedInd_strength), ...
    T_wraps.maxSquat(T_wraps.matchedInd_strength), 1000, enoughN);
% Squat weight - age regressed out
[~, ~, medDiff_squat_reg_age, CIs_squat_reg_age, ~] = ...
    getStatsWithinBWbins(binIdx_raw, binIdx_wraps, numBins_BW, ...
    T_raw.residuals_age, T_wraps.residuals_age, 1000, enoughN);

% Squat weight - meet count matched
med_squat_MCcon_raw = nan(numBins_BW, numIter_MC);
med_squat_MCcon_wraps = nan(numBins_BW, numIter_MC);
for curIter = 1:numIter_MC
    curInd_raw = MC_randSamp_raw(:,curIter);
    nonEmpty = sum(binIdx_raw(curInd_raw) == 1:numBins_BW) > 0;
    med_squat_MCcon_raw(nonEmpty, curIter) = accumarray(binIdx_raw(curInd_raw), T_raw.maxSquat(curInd_raw), [], @median);
    curInd_wraps = MC_randSamp_wraps(:,curIter);
    nonEmpty = sum(binIdx_wraps(curInd_wraps) == 1:numBins_BW) > 0;
    med_squat_MCcon_wraps(nonEmpty, curIter) = accumarray(binIdx_wraps(curInd_wraps), T_wraps.maxSquat(curInd_wraps), [], @median);
end
meanMedDiff_squat_match_MC = mean(med_squat_MCcon_wraps - med_squat_MCcon_raw,2);
CIs_squat_match_MC = prctile(med_squat_MCcon_wraps - med_squat_MCcon_raw, [2.5 97.5], 2);

fprintf('complete')

%% One meet per lifter stats

fprintf('\nGetting the Raw-Wraps stats for ''one meet per lifter'' data...')

% Get squat weights when using one meet per lifter

numIter_oneMeet = 1000;
% Pool Raw and Wraps data
dataIn = [T_raw.personID ; T_wraps.personID];
squatIn = [T_raw.maxSquat ; T_wraps.maxSquat];
binIdxIn = [binIdx_raw ; binIdx_wraps];
% Get group index for each personID
G = findgroups(dataIn);
% Index to Raw data in pooled data
rawInd = false(numel(dataIn),1);
rawInd(1:numel(T_raw.personID)) = true;
% Initialize matrix to store medians
med_raw_oneMeet = nan(numBins_BW, numIter_oneMeet);
med_wraps_oneMeet = nan(numBins_BW, numIter_oneMeet);
for i = 1:numIter_oneMeet
    % Index to all data that includes one meet per lifter (random selection)
    rows = splitapply(@(x) x(randi(numel(x))), (1:numel(dataIn))', G);    
    keepIdx = false(numel(dataIn),1);
    keepIdx(rows) = true;
    % The squat Kg, Raw-wraps index, and weight class bin index for all kept data
    squatKeep = squatIn(keepIdx);
    rawIndKeep = rawInd(keepIdx);
    binIdxKeep = binIdxIn(keepIdx);
    % Get Raw median differences
    dataExists = sum(binIdxKeep(rawIndKeep) == 1:numBins_BW) > 0;
    G_raw = findgroups(binIdxKeep(rawIndKeep));
    med_raw_oneMeet(dataExists,i) = splitapply(@median, squatKeep(rawIndKeep), G_raw);
    % Get Wraps median differences
    dataExists = sum(binIdxKeep(~rawIndKeep) == 1:numBins_BW) > 0;
    G_wraps = findgroups(binIdxKeep(~rawIndKeep));
    med_wraps_oneMeet(dataExists,i) = splitapply(@median, squatKeep(~rawIndKeep), G_wraps);
end

% Number of people per group (minimum of Raw and Wraps)
n_oneMeet = min(sum(binIdxKeep(rawIndKeep) == 1:numBins_BW),...
    sum(binIdxKeep(~rawIndKeep) == 1:numBins_BW));

medDiff_oneMeet = mean(med_wraps_oneMeet - med_raw_oneMeet, 2);
CIs_squat_oneMeet = prctile(med_wraps_oneMeet - med_raw_oneMeet, [2.5 97.5], 2);

fprintf('complete')

%% Get statistical power

fprintf('\nGetting statistical power stats...')

alphaLev = 0.01; % look for significance using this alpha
effectSizes = 2.5:2.5:15; % add these effect sizes to the Wraps data
statPowerTh = .8; % minimum statistical power

n_effectSizes = numel(effectSizes);
bins_BW_take = find(enoughN);

n_enoughBins = numel(bins_BW_take);

numIter_power = 1000;

pVals_FDR = nan(n_effectSizes, n_enoughBins, numIter_power);
fprintf('\nGetting p values for %s iterations.  Completed: ', num2str(numIter_power));
for i = 1:numIter_power  
    pVals = nan(n_effectSizes, n_enoughBins);
    for j = 1:n_enoughBins
        curInd_raw = binIdx_raw == bins_BW_take(j);
        curInd_wraps = binIdx_wraps == bins_BW_take(j);    
        curData_raw = T_raw.maxSquat(curInd_raw);
        curData_wraps = T_wraps.maxSquat(curInd_wraps);
        pVals(:,j) = getMDE_ranksum(curData_raw, curData_wraps, effectSizes);
    end
    % FDR-correct the P-values
    for j = 1:n_effectSizes
        if exist('mafdr','file') > 0
            pVals_FDR(j,:,i) = mafdr(pVals(j,:),'BHFDR',true); 
        end
    end
    counterStr(i)
end

statPower = sum(pVals_FDR < alphaLev, 3) / numIter_power;

enoughStatPower = statPower >= statPowerTh;

[~,MDE_ind] = max(enoughStatPower);

MDE = nan(1,numBins_BW);
MDE(enoughN) = effectSizes(MDE_ind);

powerAtMinEffect = nan(1,numBins_BW); 
powerAtMinEffect(enoughN) = statPower(1,:);

fprintf('\n...complete')

%% Linear relationship check; within a BW bin; squat weights versus a control variable

%{

% Input details for the control variable
curBWbin = 11;
xData = [ T_raw.Age(:) ; T_wraps.Age(:) ];
xLims = [18 75];
polyNum = 2;

% % Input details for the control variable - BW
% curBWbin = 11;
% xData = [ T_raw.BW(:) ; T_wraps.BW(:) ];
% xLims = [weightClassBins(curBWbin) weightClassBins(curBWbin+1)];
% polyNum = 1;

yData = [ T_raw.maxSquat(:) ; T_wraps.maxSquat(:) ];
yLims = [50 350];

curInd_raw = T_raw.weightClassIndex == curBWbin;
curInd_wraps = T_wraps.weightClassIndex == curBWbin;
curInd = [ curInd_raw(:) ; curInd_wraps(:) ];

n_r = sum(curInd_raw);
n_wr = sum(curInd_wraps);

col = [ zeros(n_r,3) ; repmat([1 0 0],n_wr,1)];

xPlot = max(min(xData(curInd),xLims(2)),xLims(1));
yPlot = max(min(yData(curInd),yLims(2)),yLims(1));

yFit = polyfit(xPlot, yPlot, polyNum );
xData_fit = linspace(xLims(1),xLims(2),100);
yData_fit = polyval(yFit,xData_fit);

figure
hold on
scatter(xPlot, yPlot, 15, col, 'filled', 'MarkerFaceAlpha', 0.5)
plot(xData_fit, yData_fit, 'g','LineWidth',3)

set(gca,'XLim',xLims,'YLim',yLims)

%}