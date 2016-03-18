function expt(arg_type, arg_subname)
%%% EXPT simulates an entire experiment
%%%
%%% arg_type = type of experiment (1=vary_noise; 2=vary_SNR; 3=pulse)
    
    try
        %%% Assign unique id to subject
        subid = now; % Unique subject number based on current date & time

        key_id = get_keyboard_id();
%        key_id = 7;

        [wip, wrp, oldDL, oldWL] = init_screen();
        pars = init_params();
        new_pars = reconfig_pars(arg_type, pars);

        %%% Linearize monitor
%        oldgfxlut = linearize_monitor(wip);

        disp_intro(wip, wrp, new_pars);

        mycon = calibrate(wip, wrp, key_id, pars, 1)

%        [dtseq, decseq, cicseq, nlseq] = block(wip, wrp, key_id, new_pars);

%        nlseq
%        decseq
%        cicseq
%        dtseq

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

    catch
        %%% Error Handling 
        % The try-catch block ensures that Screen will restore the display and return us
        % to the MATLAB prompt even if there is an error in our code.  Without this try-catch
        % block, Screen could still have control of the display when MATLAB throws an error, in
        % which case the user will not see the MATLAB prompt.
        if (exist('oldgfxlut')) % if linearized monitor, then reset
            reset_monitor(wip, oldgfxlut);
        end
        Screen('CloseAll');

        % Restores the mouse cursor.
        ShowCursor;
        
        % Restore preferences
        Screen('Preference', 'VisualDebugLevel', oldDL);
        Screen('Preference', 'SuppressAllWarnings', oldWL);

        % We throw the error again so the user sees the error description.
        psychrethrow(psychlasterror);
    end
end


function [wip, wrp, oldDL, oldWL] = init_screen()
%%% Initialises the Psychtoolbox screen, sets debug level, font, priority, etc.
%%%
%%% wip = window pointer
%%% wrp = window rectangle pointer

        oldWL = Screen('Preference', 'SuppressAllWarnings', 1);
        oldDL = Screen('Preference', 'VisualDebugLevel', 3);
%        PsychDebugWindowConfiguration(0,0.90) % Control opacity (for testing)
%        Screen('Preference','Verbosity', 6)
        whichScreen = max(Screen('Screens')); % Open Screen on last monitor
        HideCursor;
        [wip, wrp] = Screen('OpenWindow', whichScreen);
%        Screen('TextFont',wip, 'Courier New');
%        Screen('TextFont',wip, '-urw-urw bookman l-medium-r-normal--0-0-0-0-p-0-koi8-r');
%        Screen('TextFont',wip, '-adobe-helvetica-bold-r-normal--25-180-100-100-p-138-iso10646-1');
        Screen('TextFont',wip, '-adobe-courier-bold-r-normal--25-180-100-100-m-150-iso8859-1');
        Screen('TextSize', wip, 22);
        Screen('TextStyle', wip, 1+2);
        priorityLevel=MaxPriority(wip);
        Priority(priorityLevel);

        HideCursor;

        Screen('FillRect', wip, WhiteIndex(wip));
        Screen('Flip', wip);
end


function out_pars = reconfig_pars(arg_type, arg_pars)
%%% RECONFIG_PARS changes the levels of noise and contrast parameters based on
%%% the type of experiment.
%%%
%%% arg_type = type of experiment (1=vary_noise; 2=vary_SNR; 3=pulse)
%%% arg_pars = experiment parameters set in init_params.m

    out_pars = arg_pars; % Initialise

    %%% If type=1, copy the const value for noise parameters in both high and
    %%% low noise levels; if type=2 copy the const value for contrast into both
    %%% high and low contrast
    switch arg_type 
    case 1 % variable contrast, but constant noise
        out_pars.sd_mu.lo = out_pars.sd_mu.const;
        out_pars.sd_sd.lo = out_pars.sd_sd.const;
        out_pars.sd_mu.hi = out_pars.sd_mu.const;
        out_pars.sd_sd.hi = out_pars.sd_sd.const;
    case 2 % constant contrast, but variable noise
        out_pars.con.lo = out_pars.con.const;
        out_pars.con.hi = out_pars.con.const;
    end
end


function oldgfxlut = linearize_monitor(wip)

        GAMMA=2.1;
        screennr=0; % use main screen
        oldgfxlut = Screen('ReadNormalizedGammatable', screennr);

        clut(1:256,1) = linspace(0,1,256)';
        clut = clut.^ (1 / GAMMA);
        clut = repmat(clut,1,3);
        Screen('LoadNormalizedGammaTable', wip, clut);
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
    device=0;
    for i=1:length(name) %for each possible device
        if strcmp(name{i},deviceString) %compare the name to the name you want
            device=id(i); %grab the correct id, and exit loop
            break;
        end
    end
    if device==0 % if device wasn't found, try to look for other keyboards
        all_ixs = [];
        name_ixs = [];
        deviceString1='eyboard';%% Match any [Ky]eyboard
        deviceString2='Logitech';%% Match any [Ky]eyboard
        for i=1:length(name) %for each possible device
            if (~isempty(strfind(name{i},deviceString1)) ||...
                ~isempty(strfind(name{i},deviceString2)))
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
    if device==0 %%error checking, if device is still 0
        error('Could not match a Keyboard device');
    end

    out_dev = device;
end


function disp_intro(arg_wip, arg_wrp, arg_pars)
%%% DISP_INTRO displays instructions for participants at the start of the
%%% experiment.

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

    texeg = Screen('MakeTexture', arg_wip, stimFrame);
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
                        'In the following trials, use left and right arrow keys to indicate your choice.',...
                        'center',...
                        byi2 - 150,...
                        BlackIndex(arg_wip),...
                        60, 0, 0, 1.5);
    DrawFormattedText(arg_wip,...
                        'Press "Space" to start',...
                        'center',...
                        cy*2 - 50,...
                        BlackIndex(arg_wip),...
                        60, 0, 0, 1.5);
    Screen('Flip', arg_wip);
    WaitSecs('YieldSecs', 1);
    [KeyIsDown, endrt, KeyCode]=KbCheck;
    while(KeyCode(KbName('space')) ~= 1)
        [KeyIsDown, endrt, KeyCode]=KbCheck;
    end

    Screen('Flip', arg_wip);

    WaitSecs('YieldSecs', 0.5);

end
