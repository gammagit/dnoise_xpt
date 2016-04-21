function iti(arg_wip, arg_wrp, arg_tid, arg_dec, arg_dt, arg_pars)
%%% ITI displays the inter-trial-interval

    lumax = arg_pars.lumax;
    stimtex_bk = gen_stimtex(arg_wip, arg_wrp, arg_pars.blobsize,...
        arg_pars.stimsize, 0, arg_pars.thick, arg_pars.con,...
        0, 0, arg_pars.lumbk, arg_pars.lumax); % using dummy mu & sd
    Screen('DrawTexture', arg_wip, stimtex_bk);

    if (arg_dt < arg_pars.mindt)
        message = ['Response was too quick!\n\nTrial will be repeated.'];
        interval = arg_pars.iti_c - 1;
    else
        if (arg_tid == arg_dec)
            message = ['Correct\n\nResponse time = ', num2str(arg_dt, 2), ' secs.'];
            interval = arg_pars.iti_c - 1;
        else
            message = ['Incorrect - the correct response was ', num2str(arg_tid),...
                    '\n\nResponse time = ', num2str(arg_dt, 2), ' secs'];
            interval = arg_pars.iti_ic - 1;
        end
    end

    %%% Display correct / incorrect / too soon message
    DrawFormattedText(arg_wip,...
                        message,...
                        'center',...
                        'center',...
                        BlackIndex(arg_wip),...
                        60, 0, 0, 1.5);
    Screen('Flip', arg_wip);
    WaitSecs('YieldSecs', interval);

    %%% Draw fixation and wait for 1 sec
    Screen('DrawTexture', arg_wip, stimtex_bk);
    draw_fixation(arg_wip, arg_wrp, [lumax lumax lumax]*0.75);
    Screen('Flip', arg_wip);
    WaitSecs('YieldSecs', 1);
end
