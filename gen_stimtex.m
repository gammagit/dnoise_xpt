function out_tex = gen_stimtex(wip, wrp, arg_blobsize, arg_stimsize, arg_tid,...
    arg_thick, arg_con, arg_mu, arg_sd, arg_lumbk, arg_lumax)
%%% GEN_STIMTEX generates a Texture for a frame containing a stimulus + noise
%%% blob in the centre of the screen.
%%%
%%% out_tex = index to an OpenGL texture created using Screen('MakeTexture')
%%%
%%% wip = pointer to the Screen window
%%% wrp = pointer to the window rectangle
%%% arg_blobsize = matrix containing size ([y, x]) of the blob in the centre of
%%%     the screen containing the stimulus + noise
%%% arg_stimsize = matrix containing size of stimulus ([y, x]) within the blob
%%% arg_tid = integer containing the id of stimulus template: 0=Back, 2=T2, 5=T5
%%% arg_thick= integer containing thickness of each side of the stimulus letter
%%% arg_con = float [0,1] containing contrast value:
%%%     luminance values are contrast * S0, where intg(S0^2) = 1
%%% arg_mu = float containing mean of Gaussian noise to be added to blob
%%% arg_sd = float containing (spatial) std dev of Gaussian noise 
%%% arg_lumbk = integer containing the luminance of background
%%% arg_lumax = integer containing the maximum luminance (used for range)

    [cx, cy] = RectCenter(wrp); % get coordinates of center

    %%% Compute coordinates of stimulus blob
    bxi = cx - (arg_blobsize(2) / 2); % index of initial x-coord
    bxf = bxi + arg_blobsize(2) - 1; % index of final x-coord
    byi = cy - (arg_blobsize(1) / 2);
    byf = byi + arg_blobsize(1) - 1;

    Background = zeros(cy*2,cx*2) + arg_lumbk; % Image matrix

    if (arg_tid ~= 0) % if not background
        Blob = create_blob(arg_blobsize, arg_stimsize, arg_thick, arg_con,...
            arg_mu, arg_sd, arg_lumbk, arg_lumax, arg_tid);

        stimFrame = Background;
        stimFrame(byi:byf, bxi:bxf) = Blob;

        out_tex = Screen('MakeTexture', wip, stimFrame);
    else
        out_tex = Screen('MakeTexture', wip, Background);
    end

    clear Background Blob stimFrame
end
