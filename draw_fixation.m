function draw_fixation(wip, wrp, col)
%%% Draw fixation point in centre of screen
%%% col = colour of fixation cross, e.g. [0 0 0]

    fixlen = 30; % Length of fixation cross
    [cx,cy] = RectCenter(wrp); % Get coordinates of centre of screen

    Screen('DrawLine', wip, col, cx-(fixlen/2), cy, cx+(fixlen/2), cy, 3);
    Screen('DrawLine', wip, col, cx, cy-(fixlen/2), cx, cy+(fixlen/2), 3);
end
