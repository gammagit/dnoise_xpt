function [out_rtseq, out_decseq, out_cicseq, out_snrseq, out_stims] =...
    block(arg_wip, arg_wrp, arg_keyid, arg_pars)
%%% BLOCK simulates a block of trials and returns decisions and decision times 
%%%
%%% out_rtseq = vector of floats containing the reaction times
%%% out_decseq = vector of ints containing the sequence of decisions
%%% out_cicseq = vector of booleans indicating correct/incorrect decisions
%%% out_snrseq = vector containing noise levels for trials
%%% out_stims = cell array containing stimuli for every frame of every trial
%%%
%%% arg_wip = Screen windowPtr (see Psychtoolbox)
%%% arg_wrp = Screen rect (see Psychtoolbox)
%%% arg_keyid = int containing the ID of keyboard
%%% arg_pars = structure containing parameters of the experiment


    %%% Display background and then fixation cross
%    stimtex_bk = gen_stimtex(arg_wip, arg_wrp, arg_pars.blobsize,...
%        arg_pars.stimsize, 0, arg_pars.thick, arg_pars.con.var,...
%        0, 0, arg_pars.lumbk, arg_pars.lumax); % using dummy mu & sd
%    Screen('DrawTexture', arg_wip, stimtex_bk);
%    Screen('Flip', arg_wip);
%    draw_fixation(arg_wip, arg_wrp, [arg_pars.lumax arg_pars.lumax arg_pars.lumax]*0.75);
%    Screen('Flip', arg_wip);
%    WaitSecs('YieldSecs', 1);
%    Screen('DrawTexture', arg_wip, stimtex_bk);
%    WaitSecs('YieldSecs', 0.5);
    [VBLTime, tzero_block]=Screen('Flip', arg_wip); % Initialise start time of block
%    WaitSecs('YieldSecs', 1);

    out_rtseq = []; % vector containing RTs
    out_decseq = []; % vector containing decisions
    ctseq = []; % vector containing times (in block) for correct decisions
    out_snrseq = [];
    out_cicseq = []; % vector containing correct / incorrect
    ii = 1; jj = 1;
    total_trials = arg_pars.ntrials;
%    while ((GetSecs - tzero_block) <= arg_pars.tblock)
    while (ii <= total_trials)
        if (rand > 0.5)
            stim_id = 2;
        else
            stim_id = 5;
        end

        %%% Choose SNR either from psychometric curve or really easy trial
        %%% These easy trials help participants minimise motor mapping delay
        if (rand < arg_pars.pveasy) 
            level = 0; % trial.m uses level=0 to set very easy contrast / noise
        else %%% Randomly sample SNR level
            randorder = randperm(numel(arg_pars.con.var));
            level = randorder(1);
        end
        out_snrseq = [out_snrseq level];

        %%% Simulate trial
        [stims, dt, dec] = trial(arg_wip, arg_wrp, stim_id, level, arg_keyid, arg_pars);
        if (stim_id == dec)
            correct = 1;
            ctseq = [ctseq GetSecs-tzero_block];
        else
            correct = 0;
        end

        %%% Diplay ITI
%        iti(arg_wip, arg_wrp, stim_id, dec, correct, ctseq, tzero_block, arg_pars);
        iti_norwd(arg_wip, arg_wrp, stim_id, dec, dt, arg_pars);

        %%% If responded too quickly, then add a trial
        if (dt >= arg_pars.mindt)
            ii = ii + 1;
        else
            correct = -1; % too short
        end
        out_rtseq = [out_rtseq dt];
        out_decseq = [out_decseq dec];
        out_cicseq = [out_cicseq correct];
        out_stims{jj} = stims;
        jj = jj + 1;
    end
end
