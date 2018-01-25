function [out_pars] = analyse()
%%% Performs the following data analysis:
%%% - Plots RT distributions
%%% - Fits ex-Gaussian to each RT distribution
%%% - Looks for sequential effects

    scale_ms = 1000; % scale RTs from seconds to msec

    folder = './res/';
%    subnames = {'BBB', 'CCC', 'DDD', 'EEE', 'FFF', 'GGG', 'HHH', 'KKK',...
%                'LLL', 'MMM', 'NNN', 'OOO', 'PPP', 'QQQ', 'RRR', 'SSS',...
%                'TTT', 'UUU'};
    subnames = {'mm_pilot', 'xx_pilot', 'ah_pilot'};
    sub_id = 0;
    for ix = 1:length(subnames)
        %%% Get files for both sesssions
        subfiles = dir([folder, '*', subnames{ix}, '.mat']);

        %%% Exclude participants where calibration does not converge correctly
        flag_calib = true; % flag checks if failed calib during any session
%        for ss = 1:2 % for Expt 1
        for ss = 1:1 % changed for Expt 2 as only one session
            fileName = fullfile(folder, subfiles(ss).name);
            load(fileName);
            if (any(isnan(xvals)))
                flag_calib = false;
            end
        end
        if (flag_calib == false)
            continue; % skip this subject
        end

        %%% Write rts to output file
        sub_id = sub_id + 1; % separate ix from sub_id so that sub_id's are continuous

        %%% Write header of output file
        out_filename = [folder, 'sub', int2str(sub_id), '.csv'];
        fh = fopen(out_filename,'w');
        dlmwrite(out_filename, 'stype,rt,diff,correct', 'delimiter', '');

        %%% Read input files from both sessions
%        for ss = 1:2 % Expt 1
        for ss = 1:1 % changed for Expt 2 as only one session
            fileName = fullfile(folder, subfiles(ss).name);
            load(fileName);
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
                rtseq = [rtseq scale_ms*data{bb}.dtseq];
                levelseq = [levelseq data{bb}.nlseq];
                cicseq = [cicseq data{bb}.cicseq];
            end

            if (stype == 's')
                sno = 1; % 1 for signal
            else
                sno = 2; % 2 for noise
            end

            svec = repmat(sno, 1, length(rtseq));

            %%% Plot RT distribution and ex-Gaussian fit
            dlmwrite(out_filename, [svec', rtseq', levelseq', cicseq'], '-append');
        end
    end
end
