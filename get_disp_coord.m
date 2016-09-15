function coords = get_disp_coord(wrp)

    [coords.cx,coords.cy] = RectCenter(wrp); % Get coordinates of centre of screen

    %%% Initialise variables for displaying experiment duration
    coords.tx = coords.cx;
    coords.ty = coords.cy + 300;
    coords.trwdy = 20;
    coords.barx1 = coords.tx - (coords.cx-150);
    coords.barx2 = coords.tx + (coords.cx-150);
    coords.bary1 = coords.ty - 20;
    coords.bary2 = coords.ty + 20;
    coords.pw = 2;
    coords.fillx1 = coords.barx1 + coords.pw;
    coords.fillx2 = coords.barx2 - coords.pw;
    coords.filly1 = coords.bary1 + coords.pw;
    coords.filly2 = coords.bary2 - coords.pw;
    coords.width = coords.fillx2 - coords.fillx1; % Total width

end
