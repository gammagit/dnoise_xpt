function out_results = expt(arg_sno, arg_subname)
%%%% EXPT simulates an entire experiment
%%%%
%%%% arg_sno = session number: 1 / 2
    
%%%    try
        %%% Assign unique id to subject 
        subid = now; % Unique subject number based on current date & time

        %%% Check whether setup is for lab (ViewPixx)
        setup_lab = input('Is this lab setup [1/0] (default=1): ');
        if (isempty(setup_lab)) % make default setup lab
            setup_lab = 1;
        end
        
        %%% Set type of experiment (1=vary_noise; 2=vary_signal; 3=pulse)
        %%% stype = input('Enter session type [s/n]: ', 's');
        stype = 'n'; % Experiment 2: Vary noise
        switch(stype)
            case 's'
                exp_type = 2;
            case 'n'
                exp_type = 1;
        end

        key_id = get_keyboard_id();
%        key_id = 7;
%        KbName('UnifyKeyNames');

        [wip, wrp, oldDL, oldWL] = init_screen(setup_lab);

        InitializePsychSound(1); % init sound drivers (for beep with stim)

        pars = init_params();

       %%% Linearize monitor
       oldgfxlut = linearize_monitor(wip, setup_lab);

       %%% Test flip interval
       flipint = Screen('GetFlipInterval', wip, 50);

       disp_intro(wip, wrp, pars, key_id, flipint);

       [xvals, nc, nic, allx, allints, allresps] = calibrate(wip, wrp,...
           key_id, pars, exp_type, 1, flipint);
       out_results{1}.calibx = allx;
       out_results{1}.calibints = allints;
       out_results{1}.calibresps = allresps;
%         %%% Begin: DEBUG
%         xvals = [0.15, 0.12, 0.10, 0.07]; %[0.30, 0.21, 0.14, 0.11]; %[0.42, 0.29, 0.22]; %[0.33, 0.26, 0.22];
%         xvals = [0.13, 0.10, 0.07, 0.05]; %[0.30, 0.21, 0.14, 0.11]; %[0.42, 0.29, 0.22]; %[0.33, 0.26, 0.22];
%         nc = 5; nic = 3;
%         %%% End: DEBUG

       new_pars = reconfig_pars(exp_type, pars, xvals); % reconfig noise & con

       disp_interlude(wip, wrp, new_pars, key_id, nc, nic, flipint, arg_sno);

       disp_interblock(wip, wrp, new_pars, key_id, 0, 0, 0);
        for ii = 1:new_pars.nblocks
            [probes, dtseq, decseq, cicseq, nlseq, stimseq, stimvec, cueix] =...
                                        block(wip, wrp, key_id, new_pars, flipint);
            nc = sum(cicseq == 1);
            nic = sum(cicseq == 0);
            disp_interblock(wip, wrp, new_pars, key_id, nc, nic, ii, arg_sno);

            %%% Store everything
            out_results{ii}.xvals = xvals;
            out_results{ii}.pars = new_pars;
            out_results{ii}.probes = probes;
            out_results{ii}.dtseq = dtseq;
            out_results{ii}.decseq = decseq;
            out_results{ii}.cicseq = cicseq;
            out_results{ii}.nlseq = nlseq;
            out_results{ii}.stimseq = stimseq;
            out_results{ii}.stimvec = stimvec;
            out_results{ii}.cueix = cueix;
        end

        %%% Save results
        resfile_mat = ['res/', datestr(subid, 'ddmmm-HHMM'), '_', arg_subname, '.mat'];
        save(resfile_mat)

        %%% Close Screen
        if (exist('oldgfxlut')) % if linearized monitor, then reset
            reset_monitor(wip, oldgfxlut);
        end
        Screen('CloseAll');
        ShowCursor;
        Screen('Preference', 'VisualDebugLevel', oldDL);
        Screen('Preference', 'SuppressAllWarnings', oldWL);
        Priority(0);

%%%    catch
%%%        %%% Error Handling 
%%%        % The try-catch block ensures that Screen will restore the display and return us
%%%        % to the MATLAB prompt even if there is an error in our code.  Without this try-catch
%%%        % block, Screen could still have control of the display when MATLAB throws an error, in
%%%        % which case the user will not see the MATLAB prompt.
%%%        if (exist('oldgfxlut')) % if linearized monitor, then reset
%%%            reset_monitor(wip, oldgfxlut);
%%%        end
%%%        Screen('CloseAll');
%%%
%%%        % Restores the mouse cursor.
%%%        ShowCursor;
%%%        
%%%        % Restore preferences
%%%        Screen('Preference', 'VisualDebugLevel', oldDL);
%%%        Screen('Preference', 'SuppressAllWarnings', oldWL);
%%%
%%%        % We throw the error again so the user sees the error description.
%%%        psychrethrow(psychlasterror);
%%%    end
end


function [wip, wrp, oldDL, oldWL] = init_screen(arg_lab)
%%% Initialises the Psychtoolbox screen, sets debug level, font, priority, etc.
%%%
%%% wip = window pointer
%%% wrp = window rectangle pointer

        %%% For Datapixx
        if (arg_lab == 1) % Experiment being done in the lab
            PsychImaging('PrepareConfiguration');
            PsychImaging('AddTask', 'General', 'FloatingPoint32Bit');
            PsychImaging('AddTask', 'General', 'EnableDataPixxM16Output');
            PsychImaging('AddTask', 'FinalFormatting', 'DisplayColorCorrection', 'LookupTable'); % Using a CLUT
        end

        oldWL = Screen('Preference', 'SuppressAllWarnings', 1);
        oldDL = Screen('Preference', 'VisualDebugLevel', 3);
%        PsychDebugWindowConfiguration(0,0.90) % Control opacity (for testing)
%        Screen('Preference','Verbosity', 6)
        whichScreen = max(Screen('Screens')); % Open Screen on last monitor
        HideCursor;
        
        %%% For Datapixx (otherwise replace PsychImaging with Screen cmd
        oldVerbosity = Screen('Preference', 'Verbosity', 1);   % Don't log the GL stuff
        if (arg_lab == 1) % Experiment being done in the lab
            [wip, wrp] = PsychImaging('OpenWindow', whichScreen);
        else
            [wip, wrp] = Screen('OpenWindow', whichScreen);
        end
        Screen('Preference', 'Verbosity', oldVerbosity);
        
        try
            Screen('TextFont',wip, 'Courier New');
%        Screen('TextFont',wip, '-urw-urw bookman l-medium-r-normal--0-0-0-0-p-0-koi8-r');
%        Screen('TextFont',wip, '-adobe-helvetica-bold-r-normal--25-180-100-100-p-138-iso10646-1');
            Screen('TextSize', wip, 24);
            Screen('TextStyle', wip, 1);
        catch
            Screen('TextFont',wip, '-adobe-courier-bold-r-normal--25-180-100-100-m-150-iso8859-1');
            Screen('TextSize', wip, 20);
            Screen('TextStyle', wip, 0);
        end
        priorityLevel=MaxPriority(wip);
        Priority(priorityLevel);

        HideCursor;

        Screen('FillRect', wip, WhiteIndex(wip));
        Screen('Flip', wip);
end


function out_pars = reconfig_pars(arg_type, arg_pars, arg_xvals)
%%% RECONFIG_PARS changes the levels of noise and contrast parameters based on
%%% the type of experiment.
%%%
%%% arg_type = type of experiment (1=vary_noise; 2=vary_signal; 3=pulse)
%%% arg_pars = experiment parameters set in init_params.m

    out_pars = arg_pars; % Initialise

    %%% If type=1, copy the const value for noise parameters in both high and
    %%% low noise levels; if type=2 copy the const value for contrast into both
    %%% high and low contrast
    switch arg_type 
    case 1 % constant contrast, but variable noise
        out_pars.con.var = out_pars.con.const;
        out_pars.sd_mu.var = arg_xvals;
    case 2 % variable contrast, but constant noise
        out_pars.con.var = arg_xvals;
        out_pars.sd_mu.var = out_pars.sd_mu.const;
        out_pars.sd_sd.var = out_pars.sd_sd.const;
    end
end


function oldgfxlut = linearize_monitor(wip, arg_lab)

        GAMMA=2.87;
        screennr=0; % use main screen
        oldgfxlut = Screen('ReadNormalizedGammatable', screennr);
        
        %First load a linear ramp into the graphics card's LUT.
        Screen('LoadNormalizedGammaTable', wip, linspace(0,1,256)'*ones(1,3));
        
        lmin = 0;
        lmax = 1;
        clut(1:256,1) = linspace(lmin, lmax, 256)';
        clut = clut.^ (1 / GAMMA);
        %clut(1:16384,1) = linspace(lmin, lmax, 16384)';
        clut = repmat(clut,1,3);
        
        if (arg_lab == 1)
            PsychColorCorrection('SetLookupTable', wip, clut); % Set up the CLUT for Psychtoolbox
        else
%         clut(1:256,1) = linspace(0,1,256)';
%         clut = clut.^ (1 / GAMMA);
%         clut = repmat(clut,1,3);
            Screen('LoadNormalizedGammaTable', wip, clut);
        end

end


function reset_monitor(wip, oldgfxlut)
        
        Screen('LoadNormalizedGammatable', wip, oldgfxlut);
        Screen('Flip',wip);
end


function out_dev = get_keyboard_id()

%    deviceString='Logitech USB Receiver';%% name of the scanner trigger box
    deviceString='Keyboard';%% Match any [Ky]eyboard

    [id,name,allinfo] = GetKeyboardIndices; % get a list of all devices connected
%    allinfo{6}
    device=-1;
    for i=1:length(name) %for each possible device
        if strcmp(name{i},deviceString) %compare the name to the name you want
            device=id(i); %grab the correct id, and exit loop
            break;
        end
    end
    if device==-1 % if device wasn't found, try to look for other keyboards
        all_ixs = [];
        name_ixs = [];
        deviceString1='eyboard';%% Match any [Ky]eyboard
        deviceString2='Logitech';%% Match any [Ky]eyboard
        deviceString3='Microsoft';%% Match any Microsoft Keyboard
        for i=1:length(name) %for each possible device
            if (~isempty(strfind(name{i},deviceString1)) ||...
                ~isempty(strfind(name{i},deviceString2)) ||...
                ~isempty(strfind(name{i},deviceString3)))
                all_ixs = [all_ixs id(i)];
                name_ixs = [name_ixs i];
            end
        end
        if (numel(all_ixs) > 1)
            options = [];
            for (i=1:length(all_ixs))
                options = [options int2str(i) '=' name{name_ixs(i)} '; '];
            end
            key_choice = input(['Select keyboard: ', options]);
            device = all_ixs(key_choice);
        else
            device = all_ixs(1);
        end
    end
    if device==-1 %%error checking, if device is still 0
        error('Could not match a Keyboard device');
    end

    out_dev = device;
end


function disp_intro(arg_wip, arg_wrp, arg_pars, arg_keyid, arg_flipint)
%%% DISP_INTRO displays instructions for participants at the start of the
%%% experiment.

    [cx, cy] = RectCenter(arg_wrp); % get coordinates of center

    DrawFormattedText(arg_wip,...
                        'Welcome to the experiment! This experiment studies how we deal with noise in videos.\n\nThe experiment lasts around 1 hour 15 mins.\n\nIf you are happy to participate, please sign the consent form and TURN OFF your mobile phone.\n\nOnce you are done, press n to go to the next screen.',...
                        'center',...
                        'center',...
                        BlackIndex(arg_wip),...
                        60, 0, 0, 1.5);
    Screen('Flip', arg_wip);
    WaitSecs('YieldSecs', 2);
    [KeyIsDown, endrt, KeyCode]=KbCheck;
    while(KeyCode(KbName('n')) ~= 1)
        [KeyIsDown, endrt, KeyCode]=KbCheck;
    end

    Screen('Flip', arg_wip);

    WaitSecs('YieldSecs', 0.5);

    DrawFormattedText(arg_wip,...
                        'The experiment is split into a number of blocks. Each block lasts around five minutes.\n\nDuring each block you will be shown a series of simple videos and your task is to decide what you saw in the video.\n\nYou should use the Left and Right arrow keys to indicate your response.\n\nPress any key to do an example.',...
                        'center',...
                        'center',...
                        BlackIndex(arg_wip),...
                        60, 0, 0, 1.5);
    Screen('Flip', arg_wip);
    WaitSecs('YieldSecs', 2);
    [KeyIsDown, endrt, KeyCode]=KbCheck;
    while(~KeyIsDown)
        [KeyIsDown, endrt, KeyCode]=KbCheck;
    end

    Screen('Flip', arg_wip);

    WaitSecs('YieldSecs', 0.5);

    %%% Display a calibration trial with large contrast and chosen stim
    pahandle = prepare_audio();
    new_pars = arg_pars;
    new_pars.stim_duration = 0.2;
    dec = calib_trial(arg_wip, arg_wrp, 2, arg_keyid, new_pars, 200, 1, pahandle, arg_flipint);
    PsychPortAudio('Close', pahandle);

    DrawFormattedText(arg_wip,...
    ['Great! In the first block, you will see each video for ', num2str(arg_pars.tcalib), ' sec and then be asked for a response.\n\nThe images in some videos may seem nearly impossible to see. In these cases, give us your best estimate of what you saw. These cases helps us calibrate your vision.\n\nIn each case, try and be as *accurate* as possible.\n\nPress n to start the experiment.'],...
                        'center',...
                        'center',...
                        BlackIndex(arg_wip),...
                        60, 0, 0, 1.5);
    Screen('Flip', arg_wip);
    WaitSecs('YieldSecs', 2);
    [KeyIsDown, endrt, KeyCode]=KbCheck;
    while(KeyCode(KbName('n')) ~= 1)
        [KeyIsDown, endrt, KeyCode]=KbCheck;
    end

    Screen('Flip', arg_wip);

    WaitSecs('YieldSecs', 0.5);

    %%% Compute coordinates of stimulus blob
    bxi2 = cx - arg_pars.blobsize(2) - (arg_pars.blobsize(2) / 2); % index of initial x-coord
    bxf2 = bxi2 + arg_pars.blobsize(2) - 1; % index of final x-coord
    byi2 = cy - (arg_pars.blobsize(1) / 2);
    byf2 = byi2 + arg_pars.blobsize(1) - 1;
    bxi5 = cx + arg_pars.blobsize(2) - (arg_pars.blobsize(2) / 2); % index of initial x-coord
    bxf5 = bxi5 + arg_pars.blobsize(2) - 1; % index of final x-coord
    byi5 = cy - (arg_pars.blobsize(1) / 2);
    byf5 = byi5 + arg_pars.blobsize(1) - 1;

    Background = zeros(cy*2,cx*2) + arg_pars.lumbk; % Image matrix
    Blob2 = create_blob(arg_pars.blobsize, arg_pars.stimsize, arg_pars.thick,...
        2, arg_pars.mu, 0.05, arg_pars.lumbk, arg_pars.lumax, 2);
    Blob5 = create_blob(arg_pars.blobsize, arg_pars.stimsize, arg_pars.thick,...
        2, arg_pars.mu, 0.05, arg_pars.lumbk, arg_pars.lumax, 5);

    stimFrame = Background;
    stimFrame(byi2:byf2, bxi2:bxf2) = Blob2;
    stimFrame(byi5:byf5, bxi5:bxf5) = Blob5;

    texeg = Screen('MakeTexture', arg_wip, stimFrame, [], [], 2);
    Screen('DrawTexture', arg_wip, texeg);

    DrawFormattedText(arg_wip,...
                        'Left',...
                        bxi2 + 70,...
                        byi2 + 200,...
                        BlackIndex(arg_wip),...
                        60, 0, 0, 1.5);
    DrawFormattedText(arg_wip,...
                        'Right',...
                        bxi5 + 70,...
                        byi5 + 200,...
                        BlackIndex(arg_wip),...
                        60, 0, 0, 1.5);
    DrawFormattedText(arg_wip,...
                        ['Each of the following videos will be shown for ', num2str(arg_pars.tcalib), ' sec.\n\nUse Left and Right arrow keys to indicate your choice after seeing the video.'],...
                        'center',...
                        byi2 - 150,...
                        BlackIndex(arg_wip),...
                        60, 0, 0, 1.5);
    DrawFormattedText(arg_wip,...
                        'Press any key to start',...
                        'center',...
                        cy*2 - 50,...
                        BlackIndex(arg_wip),...
                        60, 0, 0, 1.5);
    Screen('Flip', arg_wip);
    WaitSecs('YieldSecs', 1);
    [KeyIsDown, endrt, KeyCode]=KbCheck;
    while(~KeyIsDown)
        [KeyIsDown, endrt, KeyCode]=KbCheck;
    end

    Screen('Flip', arg_wip);

    WaitSecs('YieldSecs', 0.5);

end


function disp_interlude(arg_wip, arg_wrp, arg_pars, arg_keyid, arg_nc, arg_nic, arg_flipint, arg_sno)
%%% DISP_INTERLUDE displays instructions after calibration and before actual
%%% experiment.

    [cx, cy] = RectCenter(arg_wrp); % get coordinates of center

    %%% Message: Number of correct / incorrect
    DrawFormattedText(arg_wip,...
                        ['Thanks! In that block, you made ', num2str(arg_nc), ' correct decisions and ', num2str(arg_nic), ' incorrect decisions.\n\nPress n to proceed.'],...
                        'center',...
                        'center',...
                        BlackIndex(arg_wip),...
                        60, 0, 0, 1.5);
    Screen('Flip', arg_wip);
    WaitSecs('YieldSecs', 2);
    [KeyIsDown, endrt, KeyCode]=KbCheck;
    while(KeyCode(KbName('n')) ~= 1)
        [KeyIsDown, endrt, KeyCode]=KbCheck;
    end

    Screen('Flip', arg_wip);

    WaitSecs('YieldSecs', 0.5);

    %%% Message: Part1 -> Part2
    DrawFormattedText(arg_wip,...
                        ['In the previous block, each video consisted of only one number and the auditory tone was played only once. From now on, an auditory tone will be played at multiple points in the video. Your task is to indicate, after each tone, what number was present in the video *at the time* that each tone was played. \n\nFor each tone, you must respond within ', num2str(arg_pars.max_rt), 's of the tone being played. Try and make these decisions as quickly AS WELL AS as accurately as you can.\n\nPress any key to do some examples. For each tone, indicate your decisions using the LEFT or RIGHT arrow keys.'],...
                        'center',...
                        'center',...
                        BlackIndex(arg_wip),...
                        60, 0, 0, 1.5);
    Screen('Flip', arg_wip);
    WaitSecs('YieldSecs', 3);
    [KeyIsDown, endrt, KeyCode]=KbCheck;
    while(~KeyIsDown)
        [KeyIsDown, endrt, KeyCode]=KbCheck;
    end

    Screen('Flip', arg_wip);

    WaitSecs('YieldSecs', 0.5);

    eg_pars = arg_pars;
    eg_pars.ntrials = 20; % number of example trials

    [probes, dtseq, decseq, cicseq, nlseq, stimseq, stimvec, cueix] =...
                                block(arg_wip, arg_wrp, arg_keyid, eg_pars, arg_flipint);
    nc = sum(cicseq == 1);
    nic = sum(cicseq == 0);
    disp_interblock(arg_wip, arg_wrp, arg_pars, arg_keyid, nc, nic, -1, arg_sno);

%    for(ii = 1:arg_pars.neg)
        %% Display an example trial
%        if (rand > 0.5)
%            stim_id = 2;
%        else
%            stim_id = 5;
%        end
%        if (rand > 0.5)
%            level = 3; % easy
%        else
%            level = 0; % v easy
%        end
%        pahandle = prepare_audio();
%        [stims, dt, dec] = trial(arg_wip, arg_wrp, stim_id, level, arg_keyid, arg_pars, pahandle, arg_flipint);
%        PsychPortAudio('Close', pahandle);
%        iti_norwd(arg_wip, arg_wrp, stim_id, dec, dt, arg_pars);
%    end
%    DrawFormattedText(arg_wip,...
%                      ['If you have any questions you can ask the experimenter now.\n\nPress any key when you are ready to start.'],...
%                        'center',...
%                        'center',...
%                        BlackIndex(arg_wip),...
%                        60, 0, 0, 1.5);
%    Screen('Flip', arg_wip);
%    WaitSecs('YieldSecs', 1);
%    [KeyIsDown, endrt, KeyCode]=KbCheck;
%    while(~KeyIsDown)
%        [KeyIsDown, endrt, KeyCode]=KbCheck;
%    end
%    Screen('Flip', arg_wip);
%    WaitSecs('YieldSecs', 0.5);

end

function disp_interblock(arg_wip, arg_wrp, arg_pars, arg_keyid, arg_nc,...
                         arg_nic, arg_bid, arg_sno)
%%% DISP_PREBLOCK displays instructions before the start of each block

    [cx, cy] = RectCenter(arg_wrp); % get coordinates of center

    %%% Compute coordinates of stimulus blob
    bxi2 = cx - arg_pars.blobsize(2) - (arg_pars.blobsize(2) / 2); % index of initial x-coord
    bxf2 = bxi2 + arg_pars.blobsize(2) - 1; % index of final x-coord
    byi2 = cy - (arg_pars.blobsize(1) / 2);
    byf2 = byi2 + arg_pars.blobsize(1) - 1;
    bxi5 = cx + arg_pars.blobsize(2) - (arg_pars.blobsize(2) / 2); % index of initial x-coord
    bxf5 = bxi5 + arg_pars.blobsize(2) - 1; % index of final x-coord
    byi5 = cy - (arg_pars.blobsize(1) / 2);
    byf5 = byi5 + arg_pars.blobsize(1) - 1;

    Background = zeros(cy*2,cx*2) + arg_pars.lumbk; % Image matrix
    Blob2 = create_blob(arg_pars.blobsize, arg_pars.stimsize, arg_pars.thick,...
        2, arg_pars.mu, 0.05, arg_pars.lumbk, arg_pars.lumax, 2);
    Blob5 = create_blob(arg_pars.blobsize, arg_pars.stimsize, arg_pars.thick,...
        2, arg_pars.mu, 0.05, arg_pars.lumbk, arg_pars.lumax, 5);

    stimFrame = Background;
    stimFrame(byi2:byf2, bxi2:bxf2) = Blob2;
    stimFrame(byi5:byf5, bxi5:bxf5) = Blob5;

    if (arg_bid == 0)
        texeg = Screen('MakeTexture', arg_wip, stimFrame, [], [], 2);
        Screen('DrawTexture', arg_wip, texeg);

        DrawFormattedText(arg_wip,...
                            'Left',...
                            bxi2 + 70,...
                            byi2 + 200,...
                            BlackIndex(arg_wip),...
                            60, 0, 0, 1.5);
        DrawFormattedText(arg_wip,...
                            'Right',...
                            bxi5 + 70,...
                            byi5 + 200,...
                            BlackIndex(arg_wip),...
                            60, 0, 0, 1.5);
        DrawFormattedText(arg_wip,...
                            ['After each tone, use Left and Right arrow keys to indicate your choice.\n\nMake decisions as *quickly* and *accurately* as you can.'],...
                            'center',...
                            byi2 - 200,...
                            BlackIndex(arg_wip),...
                            60, 0, 0, 1.5);
        DrawFormattedText(arg_wip,...
                            'Press any key to start',...
                            'center',...
                            cy*2 - 50,...
                            BlackIndex(arg_wip),...
                            60, 0, 0, 1.5);
        Screen('Flip', arg_wip);
        WaitSecs('YieldSecs', 1);
        [KeyIsDown, endrt, KeyCode]=KbCheck;
        while(~KeyIsDown)
            [KeyIsDown, endrt, KeyCode]=KbCheck;
        end
        Screen('Flip', arg_wip);
        WaitSecs('YieldSecs', 0.5);
    elseif (arg_bid == -1) % At the end of training block
        %%% Message: Number of correct / incorrect
        DrawFormattedText(arg_wip,...
                            ['In that block, you made ', num2str(arg_nc), ' correct decisions and ', num2str(arg_nic), ' incorrect decisions.\n\nPress n to proceed.'],...
                            'center',...
                            'center',...
                            BlackIndex(arg_wip),...
                            60, 0, 0, 1.5);
        Screen('Flip', arg_wip);
        WaitSecs('YieldSecs', 2);
        [KeyIsDown, endrt, KeyCode]=KbCheck;
        while(KeyCode(KbName('n')) ~= 1)
            [KeyIsDown, endrt, KeyCode]=KbCheck;
        end
        Screen('Flip', arg_wip);
        WaitSecs('YieldSecs', 0.5);

        endstring = 'If you have any questions you can ask the experimenter now.\n\nPress any key when you are ready to start.';
        DrawFormattedText(arg_wip,...
                            endstring,...
                            'center',...
                            'center',...
                            BlackIndex(arg_wip),...
                            60, 0, 0, 1.5);
        Screen('Flip', arg_wip);
        WaitSecs('YieldSecs', 2);
        [KeyIsDown, endrt, KeyCode]=KbCheck;
        while(~KeyIsDown)
            [KeyIsDown, endrt, KeyCode]=KbCheck;
        end
        Screen('Flip', arg_wip);
        WaitSecs('YieldSecs', 0.5);
    elseif (arg_bid == arg_pars.nblocks)
        %%% Message: Number of correct / incorrect
        DrawFormattedText(arg_wip,...
                            ['In that block, you made ', num2str(arg_nc), ' correct decisions and ', num2str(arg_nic), ' incorrect decisions.\n\nPress n to proceed.'],...
                            'center',...
                            'center',...
                            BlackIndex(arg_wip),...
                            60, 0, 0, 1.5);
        Screen('Flip', arg_wip);
        WaitSecs('YieldSecs', 2);
        [KeyIsDown, endrt, KeyCode]=KbCheck;
        while(KeyCode(KbName('n')) ~= 1)
            [KeyIsDown, endrt, KeyCode]=KbCheck;
        end
        Screen('Flip', arg_wip);
        WaitSecs('YieldSecs', 0.5);

        %%% End of experiment
%         if (arg_sno == 1)
%             endstring = 'That is the end of the session!\n\nPlease organise a time with the experimenter for the second session.\n\nThank you.';
%         else
            endstring = 'That is the end of the experiment!\n\nThank you for participating.';
%         end
        DrawFormattedText(arg_wip,...
                            endstring,...
                            'center',...
                            'center',...
                            BlackIndex(arg_wip),...
                            60, 0, 0, 1.5);
        Screen('Flip', arg_wip);
        WaitSecs('YieldSecs', 2);
        [KeyIsDown, endrt, KeyCode]=KbCheck;
        while(KeyCode(KbName('n')) ~= 1)
            [KeyIsDown, endrt, KeyCode]=KbCheck;
        end
        Screen('Flip', arg_wip);
        WaitSecs('YieldSecs', 0.5);
    else
        %%% Message: Number of correct / incorrect
        DrawFormattedText(arg_wip,...
                            ['In that block, you made ', num2str(arg_nc), ' correct decisions and ', num2str(arg_nic), ' incorrect decisions.\n\nPress n to proceed.'],...
                            'center',...
                            'center',...
                            BlackIndex(arg_wip),...
                            60, 0, 0, 1.5);
        Screen('Flip', arg_wip);
        WaitSecs('YieldSecs', 2);
        [KeyIsDown, endrt, KeyCode]=KbCheck;
        while(KeyCode(KbName('n')) ~= 1)
            [KeyIsDown, endrt, KeyCode]=KbCheck;
        end
        Screen('Flip', arg_wip);
        WaitSecs('YieldSecs', 0.5);

        %%% End of experiment
        DrawFormattedText(arg_wip,...
                            ['Next block is block # ', num2str(arg_bid+1), ' out of ', num2str(arg_pars.nblocks), '.\n\nThe experiment will proceed after 15 secs. Please take a brief rest.'],...
                            'center',...
                            'center',...
                            BlackIndex(arg_wip),...
                            60, 0, 0, 1.5);
        Screen('Flip', arg_wip);
        %%% DEBUG
%         WaitSecs('YieldSecs', 3);
        %%% DEBUG
        WaitSecs('YieldSecs', 15);

        texeg = Screen('MakeTexture', arg_wip, stimFrame, [], [], 2);
        Screen('DrawTexture', arg_wip, texeg);
        DrawFormattedText(arg_wip,...
                            'Left',...
                            bxi2 + 70,...
                            byi2 + 200,...
                            BlackIndex(arg_wip),...
                            60, 0, 0, 1.5);
        DrawFormattedText(arg_wip,...
                            'Right',...
                            bxi5 + 70,...
                            byi5 + 200,...
                            BlackIndex(arg_wip),...
                            60, 0, 0, 1.5);
        DrawFormattedText(arg_wip,...
                            ['After each tone, use Left and Right arrow keys to indicate your choice.\n\nMake decisions as *quickly* and *accurately* as you can.'],...
                            'center',...
                            byi2 - 200,...
                            BlackIndex(arg_wip),...
                            60, 0, 0, 1.5);
        DrawFormattedText(arg_wip,...
                            'When you are ready, press any key to start',...
                            'center',...
                            cy*2 - 50,...
                            BlackIndex(arg_wip),...
                            60, 0, 0, 1.5);
        Screen('Flip', arg_wip);
        WaitSecs('YieldSecs', 1);
        [KeyIsDown, endrt, KeyCode]=KbCheck;
        while(~KeyIsDown)
            [KeyIsDown, endrt, KeyCode]=KbCheck;
        end
        Screen('Flip', arg_wip);
        WaitSecs('YieldSecs', 0.5);
    end
end
