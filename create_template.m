function out_T = create_template(arg_winsize, arg_tsize, arg_thick, arg_con,...
    arg_tid)
%%% CREATE_TEMPLATE returns matrices containing pixel values for two templates
%%%
%%% out_T2 = matrix containing pixel values for template "2"
%%% out_T5 = matrix containing pixel values for template "5"
%%%
%%% arg_winsize = matrix containing size of window ([nrows, ncols])
%%% arg_tsize = matrix containing size of template ([nrows, ncols])
%%% arg_thick= integer containing thickness of each side of the template
%%% arg_con = float [0,1] containing contrast value:
%%%     luminance values are contrast * S0, where intg(S0^2) = 1
%%% arg_tid = integer indicating the template id: 2=T2, 5=T5

    Background = zeros(arg_tsize);

    %%% Construct vector hloc containing location of the 3 horizontal bars
    hloc(1) = 1;
    hloc(2) = arg_thick + get_vlen(arg_tsize, arg_thick) + 1;
    hloc(3) = arg_tsize(1) - arg_thick + 1;

    %%% Construct vectors vloc containing location of the 2 horizontal bars
    vloc_T2(1) = arg_tsize(2) - arg_thick + 1; % upper bar at right
    vloc_T2(2) = 1; % lower bar at left

    vloc_T5(1) = 1; % upper bar at left
    vloc_T5(2) = arg_tsize(2) - arg_thick + 1; % lower bar at right

    %%% Construct the two templates by overwriting 1's at hloc, vloc
    hbar_rows = [hloc(1) : hloc(1)+arg_thick-1,...
        hloc(2) : hloc(2)+arg_thick-1,...
        hloc(3) : hloc(3)+arg_thick-1]; % rows containing horizontal bars

    if (arg_tid == 2)
        inner_T = Background; % initialise to background
        inner_T(hbar_rows, :) = 1; % add horizontal bars
        inner_T(hloc(1)+arg_thick : hloc(2)-1,...
            vloc_T2(1) : vloc_T2(1)+arg_thick-1) = 1; % upper vertical segment
        inner_T(hloc(2)+arg_thick : hloc(3)-1,...
            vloc_T2(2) : vloc_T2(2)+arg_thick-1) = 1; % lower vertical segment
    elseif (arg_tid == 5)
        inner_T = Background; % initialise to background
        inner_T(hbar_rows, :) = 1; % add horizontal bars
        inner_T(hloc(1)+arg_thick : hloc(2)-1,...
            vloc_T5(1) : vloc_T5(1)+arg_thick-1) = 1; % upper vertical segment
        inner_T(hloc(2)+arg_thick : hloc(3)-1,...
            vloc_T5(2) : vloc_T5(2)+arg_thick-1) = 1; % lower vertical segment
    else
        error('Incorrect template ID requested');
    end

    unscaled_T = add_border(inner_T, arg_winsize, arg_tsize);

    out_T = rescale_template(unscaled_T, arg_con);
end


function out_vlen = get_vlen(arg_tsize, arg_thick)
%%% GET_VLEN returns the length of vertical bars in the template
%%%
%%% out_vlen = integer containing the length of (both) vertical bars in 2 & 5
%%% arg_tsize = matrix containing size of template ([nrows, ncols])
%%% arg_thick= integer containing thickness of each side of the template

    height = arg_tsize(1);
    total_thick = arg_thick * 3; % total thickness of three horizontal bars
    out_vlen = floor((height - total_thick) / 2); % interval between-bars
end


function [out_trow, out_tcol] = get_tloc(arg_winsize, arg_tsize);
%%% GET_TLOC returns the starting location for the template matrix within the
%%% window matrix. Places the template at the centre.
%%%
%%% out_trow = integer containing the row number where template starts
%%% out_tcol = integer containing the column number where template starts
%%% arg_winsize = matrix containing size of window ([nrows, ncols])
%%% arg_tsize = matrix containing size of template ([nrows, ncols])

    nempty_rows = arg_winsize(1) - arg_tsize(1);
    nempty_cols = arg_winsize(2) - arg_tsize(2);
    out_trow = floor(nempty_rows / 2) + 1;
    out_tcol = floor(nempty_cols / 2) + 1;
end


function out_T = add_border(arg_T, arg_winsize, arg_tsize)
%%% ADD_BORDER constructs the entire window by surrounding templates with
%%% background.

    [trow, tcol] = get_tloc(arg_winsize, arg_tsize);
    out_T = zeros(arg_winsize);
    out_T(trow : trow+arg_tsize(1)-1, tcol : tcol+arg_tsize(2)-1) = arg_T;
end


function out_T = rescale_template(arg_T, arg_con)
%%% Rescale stimuli so that stimuli are contrast * S0, where S0 is normalised
%%% such that total energy (i.e. integral of S0^2) = 1.

    energy = sum(sum(arg_T.^2)); % total energy of signal
    scaled_stims = arg_T ./ (sqrt(energy)); % rescaled s:t intg(s^2) = 1
    out_T = arg_con * scaled_stims;
end
