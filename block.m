function [out_rtseq out_decseq out_cicseq out_nlseq] = block(arg_wip, arg_wrp, arg_keyid, arg_pars)
%%% BLOCK simulates a block of trials and returns decisions and decision times 
%%%
%%% out_rtseq = vector of floats containing the reaction times
%%% out_decseq = vector of ints containing the sequence of decisions
%%% out_cicseq = vector of booleans indicating correct/incorrect decisions
%%% out_nlseq = vector containing noise levels for trials
%%%
%%% arg_wip = Screen windowPtr (see Psychtoolbox)
%%% arg_wrp = Screen rect (see Psychtoolbox)
%%% arg_keyid = int containing the ID of keyboard
%%% arg_pars = structure containing parameters of the experiment


    %%% Display background and then fixation cross
%    stimtex_bk = gen_stimtex(arg_wip, arg_wrp, arg_pars.blobsize,...
%        arg_pars.stimsize, 0, arg_pars.thick, arg_pars.con,...
%        0, 0, arg_pars.lumbk, arg_pars.lumax); % using dummy mu & sd
%    Screen('DrawTexture', arg_wip, stimtex_bk);
%    Screen('Flip', arg_wip);
%    draw_fixation(arg_wip, arg_wrp, [arg_pars.lumax arg_pars.lumax arg_pars.lumax]*0.75);
%    Screen('Flip', arg_wip);
%    WaitSecs('YieldSecs', 1);
%    Screen('DrawTexture', arg_wip, stimtex_bk);
%    WaitSecs('YieldSecs', 0.5);
    [VBLTime tzero_block]=Screen('Flip', arg_wip); % Initialise start time of block
%    WaitSecs('YieldSecs', 1);

    out_rtseq = []; % vector containing RTs
    out_decseq = []; % vector containing decisions
    ctseq = []; % vector containing times (in block) for correct decisions
    out_nlseq = [];
    out_cicseq = []; % vector containing correct / incorrect
    while ((GetSecs - tzero_block) <= arg_pars.tblock)
        if (rand > 0.5)
            stim_id = 2;
        else
            stim_id = 5;
        end
        if (rand > 0.5)
            level = 1; % low noise level for trial
        else
            level = 2;
        end
        out_nlseq = [out_nlseq level];


        %%% Simulate trial
        [dt, dec] = trial(arg_wip, arg_wrp, stim_id, level, arg_keyid, arg_pars);
        if (stim_id == dec)
            correct = true;
            ctseq = [ctseq GetSecs-tzero_block];
        else
            correct = false;
        end

        %%% Diplay ITI
        iti(arg_wip, arg_wrp, stim_id, dec, correct, ctseq, tzero_block, arg_pars);

        out_rtseq = [out_rtseq dt];
        out_decseq = [out_decseq dec];
        out_cicseq = [out_cicseq correct];
    end
end