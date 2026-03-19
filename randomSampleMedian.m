function med = randomSampleMedian(dataIn)

n = numel(dataIn);

sampleInd_wr = randi(n, [n 1]); % index to random sample, with replacement

randSamp_wr = dataIn(sampleInd_wr); % the random sample

med = median(randSamp_wr,'omitnan');