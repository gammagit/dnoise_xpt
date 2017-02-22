function [out_pars] = analyse()
%%% Performs the following data analysis:
%%% - Plots RT distributions
%%% - Fits ex-Gaussian to each RT distribution
%%% - Looks for sequential effects

    scale_ms = 1000; % scale RTs from seconds to msec

    folder = './res/';
    allfiles = dir([folder, '*.mat']);
    sub_id = 1;
    for fileix = 1:length(allfiles)
        fileName = fullfile(folder, allfiles(fileix).name);
        load(fileName);

        %%% Process only one type of experiment (to begin with!!!)
        if (stype == 'n')
            continue;
        end

        data = out_results;

        numlevels = numel(unique(data{1}.nlseq)) - 1; % subtract 1 for level 0
        for (ll = 1:numlevels)
            crtseq{ll} = []; % Init vector for correct RTs at level across blocks
        end
        rtseq = [];
        levelseq = [];
        cicseq = [];

        %%% for each block
        numblocks = size(data, 2);
        for bb = 1:numblocks
            %%% for each level
%            for ll = 1:numlevels
%                ixllc = find(data{bb}.nlseq == ll &...
%                            data{bb}.cicseq == 1); % indices for correct+level
%                crtseq{ll} = [crtseq{ll} scale_ms*data{bb}.dtseq(ixllc)]; % concatenate
%            end
            rtseq = [rtseq scale_ms*data{bb}.dtseq];
            levelseq = [levelseq data{bb}.nlseq];
            cicseq = [cicseq data{bb}.cicseq];
        end


        %%% Plot RT distribution and ex-Gaussian fit
        out_filename = [folder, 'sub', int2str(sub_id), '.csv'];
        sub_id = sub_id + 1;
        dlmwrite(out_filename, 'rt,diff,correct', 'delimiter', '');
        dlmwrite(out_filename, [rtseq', levelseq', cicseq'], '-append');
    end

    %%% Plot RT distribution
%    figure
%    for ll = 1:numlevels
%        subplot(3,1,ll)
%        min(crtseq{ll})
%        eg_init = [200, 100, 40]; % Initial value (based on Matzke & Wagenmakers)
%        eg_pars = egfit(crtseq{ll}, eg_init, [1.e-4, 1.e-4, 2000]);
%        plotegfit(crtseq{ll}, eg_pars, 50);
%        switch ll
%        case 1
%            title('RTs (Correct) for Hard')
%        case 2
%            title('RTs (Correct) for Medium')
%        case 3
%            title('RTs (Correct) for Easy')
%        end
%        xlabel('time')
%        ylabel('frequency')

%        out_pars{ll} = eg_pars;

%        rtvec = crtseq{ll};
%        condvec = repmat(ll, 1, length(rtvec));
%    end

%    %%% Goodness-of-fit
%    nreps = 1000; % Number of replicated (simulated) data sets
%    treps = 150; % Number of trials in each replication
%
%    for ll = 1:numlevels
%        %%% Get median of data
%        med_data = median(crtseq{ll});
%
%        %%% Compare with predicted median
%    end

end
