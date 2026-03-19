function dataReorg = reorganizeAfterAccumarray(data, ind)

data_cat = cat(1,data{:});

if islogical(data_cat)
    dataReorg = false(numel(ind),1);
else
    dataReorg = nan(numel(ind),1);
end

dataReorg(ind) = data_cat;
