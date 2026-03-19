function pVals = getMDE_ranksum(data_group1, data_group2, effectSizes)

n_group1 = numel(data_group1);
n_group2 = numel(data_group2);

numEffectSizes = numel(effectSizes);

% Get random sample (w/ replacement) - group 1
sampleRand = randi(n_group1, [n_group1 1]); % index to random sample, with replacement
randSamp_group1 = data_group1(sampleRand); % the random sample
% Get random sample (w/ replacement) - group 2
sampleRand = randi(n_group2, [n_group2 1]);
randSamp_group2 = data_group2(sampleRand);
% Group 2 plus the effect sizes
group2_withEffect = randSamp_group2(:) + effectSizes(:)';
% Run the rank sum tests for each effect size
pVals = nan(1,numEffectSizes);
if exist('ranksum','file') == 0
    return
end
for i = 1:numEffectSizes
    pVals(i) = ranksum(randSamp_group1(:), group2_withEffect(:,i));
end





