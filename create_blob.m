function out_Blob = create_blob(arg_winsize, arg_tsize, arg_thick, arg_con,...
    arg_mu, arg_sd, arg_lumbk, arg_lumax, arg_tid)
%%% CREATE_STIM returns a matrix containing the stimulus formed by combining
%%% a template and noise.
%%%
%%% arg_tid = template id: 2=T2, 5=T5

    Template = create_template(arg_winsize, arg_tsize, arg_thick, arg_con, arg_tid);
    norm_Blob = add_noise(Template, arg_mu, arg_sd); % pixel values in [-1,1]

    out_Blob = convert_lum(norm_Blob, arg_lumbk, arg_lumax);

end


function out_Blob = convert_lum(arg_Blob, arg_lumbk, arg_lumax)
%%% CONVERT_LUM converts matrix of normalised stimulus values into luminances.
%%%
    mid_lum = arg_lumax/2;
    out_Blob = (mid_lum .* arg_Blob) + arg_lumbk;
end
