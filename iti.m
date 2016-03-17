function iti(arg_wip, arg_wrp, arg_tid, arg_dec, arg_correct, arg_ctseq, arg_tzero, arg_pars)
%%% ITI displays the inter-trial-interval

    lumax = arg_pars.lumax;
    ttime = arg_pars.tblock;
    dtime = GetSecs - arg_tzero; % time at which the decision was made (approx)
    if (arg_correct)
        delay = arg_pars.iti_c;
    else
        delay = arg_pars.iti_ic;
    end
    ifi = Screen('GetFlipInterval', arg_wip);
    rr = 2; % Refresh every 2nd frame
    niter = delay / ((rr-0.5)*ifi); % Total iterations
%    niter_anim = floor((1/2) * niter); % Number of iterations to display anim
    niter_fix = floor((1/4) * (arg_pars.iti_c / ((rr-0.5)*ifi)));
    niter_blank = niter_fix;
    niter_anim = niter - (niter_fix + niter_blank);
%    niter_noblank = floor((3/4) * niter); % niter for animation or fixation
    stimtex_bk = gen_stimtex(arg_wip, arg_wrp, arg_pars.blobsize,...
        arg_pars.stimsize, 0, arg_pars.thick, arg_pars.con,...
        0, 0, arg_pars.lumbk, arg_pars.lumax); % using dummy mu & sd

    %%% Display reward and a timer animation
    start_time = GetSecs;
    for ii = 1:niter
        %%% Create progress clock in the background
        Screen('DrawTexture', arg_wip, stimtex_bk);

        if (ii <= niter_anim) % display animation (if correct) as well as reward
            if (arg_correct) % animate
                disp_time_n_rwd(arg_wip, arg_wrp, ttime, arg_tzero, arg_ctseq(1:end-1));
                plot_rwd_anim(arg_wip, arg_wrp, ttime, dtime, ii, niter_anim);
            else % no animation, just display previous rewards
                disp_time_n_rwd(arg_wip, arg_wrp, ttime, arg_tzero, arg_ctseq);
            end
        elseif (ii <= niter_anim + niter_fix) % stop displaying anything after this point
            draw_fixation(arg_wip, arg_wrp, [lumax lumax lumax]*0.75);
        end

        %%% Refresh screen according to rr (see DriftDemo2 for logic)
        Screen('Flip', arg_wip, start_time + ((rr-0.5)*ifi*ii));
    end
end


function plot_rwd_anim(arg_wip, arg_wrp, ttime, dtime, ii, arg_nframes)
%%% Plots the position to display reward, animating the motion from location
%%% of stimulus to progress bar.

    %%% Create textures for money bags
    imdata_rwd1=imread(char('img/money_bag.png'), 'BackgroundColor', [0.5 0.5 0.5]);
    [rwdht1,rwdwd1,z] = size(imdata_rwd1); % Get size of reward image
    texrwd1=Screen('MakeTexture', arg_wip, imdata_rwd1);
    imdata_rwd2=imread(char('img/money_bag_vsmall.png'), 'BackgroundColor', [0.5 0.5 0.5]);
    [rwdht2,rwdwd2,z] = size(imdata_rwd2); % Get size of reward image
    texrwd2=Screen('MakeTexture', arg_wip, imdata_rwd2);
    rwdwd = rwdwd1; % By default, display big image (except when animating)
    rwdht = rwdht1;
    texrwd = texrwd1;

    iter_noanim = arg_nframes / 2; % Number of iterations for no animation
    disp_coords = get_disp_coord(arg_wrp);
    iter_noanim_start = round(iter_noanim / 2); % Reward does not move at start
    iter_noanim_end = arg_nframes - round(iter_noanim / 2); % Reward does not move at end
    rwdx0 = disp_coords.cx - (rwdwd/2);
    rwdy0 = disp_coords.cy - (rwdht/2);

    cwidth = ((ttime - dtime) / ttime) * disp_coords.width;
    rwdxf = disp_coords.fillx1 + cwidth;
    rwdyf = disp_coords.filly1 - 50;
    delx = (rwdxf - rwdx0) / (arg_nframes-iter_noanim);
    dely = (rwdyf - rwdy0) / (arg_nframes-iter_noanim);

    if (ii < iter_noanim_start) % No animation for the first quarter
        rwdx = rwdx0;
        rwdy = rwdy0;
        rwdid = 1;
    elseif (ii > iter_noanim_end) % No animation for last quarter
        rwdx = rwdxf;
        rwdy = rwdyf;
        rwdid = 2;
    else
        rwdx = rwdx0 + delx*(ii - iter_noanim_start);
        rwdy = rwdy0 + dely*(ii - iter_noanim_start);
        rwdid = 2;
    end

    if (rwdid == 2) % at some point in animation start using small image
        rwdwd = rwdwd2;
        rwdht = rwdht2;
        texrwd = texrwd2;
    end
    Screen('DrawTexture',...
            arg_wip,...
            texrwd,...
            [0 0 rwdwd rwdht],...
            [rwdx rwdy rwdx+rwdwd rwdy+rwdht],...
            0,...
            0);
end


function disp_time_n_rwd(arg_wip,...
                         arg_wrp,...
                         ttime,...
                         tzero,...
                         ctseq)
%%% Display the time left in the block as well as the accumulated reward
%%%
%%% ttime = total duration of block
%%% tzero = time at which the block started
%%% crwd = Total reward accumulated
%%% ctseq = sequence of times at which correct decision was made

    disp_coords = get_disp_coord(arg_wrp);
    Screen(arg_wip,...
            'FrameRect',...
            [0 0 0],...
            [disp_coords.barx1 disp_coords.bary1 disp_coords.barx2 disp_coords.bary2],...
            disp_coords.pw);
    cwidth = ((ttime-(GetSecs-tzero)) / ttime) * disp_coords.width;
    disp_coords.fillx2 = disp_coords.fillx1 + cwidth;
    if(cwidth >= 1)
        Screen(arg_wip,...
                'FillRect',...
                [200 200 200],...
                [disp_coords.fillx1 disp_coords.filly1 disp_coords.fillx2 disp_coords.filly2],...
                disp_coords.pw);
    end
%    DrawFormattedText(arg_wip,...
%                        'Total time left',...
%                        (disp_coords.barx1+disp_coords.barx2)/2 - 120,...
%                        (disp_coords.bary1 + disp_coords.bary2)/2 - 12,...
%                        0,...
%                        50,...
%                        BlackIndex(arg_wip));

    %%% Draw times of reward along progress bar
    imdata_rwd=imread(char('img/money_bag_vsmall.png'), 'BackgroundColor', [0.5 0.5 0.5]);
    [rwdht,rwdwd,z] = size(imdata_rwd); % Get size of reward image
    texrwd=Screen('MakeTexture', arg_wip, imdata_rwd);
    for ii = 1:length(ctseq)
        dtci = ctseq(ii);
        loci = ((ttime - dtci) / ttime) * disp_coords.width;
        rwdx = disp_coords.fillx1 + loci;
        rwdy = disp_coords.filly1 - 50;
        Screen('DrawTexture',...
                arg_wip,...
                texrwd,...
                [0 0 rwdwd rwdht],...
                [rwdx rwdy rwdx+rwdwd rwdy+rwdht],...
                0,...
                0);
    end

end
