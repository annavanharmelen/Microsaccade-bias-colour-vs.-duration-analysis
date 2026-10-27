%% Step2-- gaze-shift calculation

%% start clea
clear; clc; close all;

%% parameter
oneOrTwoD  = 1;
oneOrTwoD_options = {'_1D','_2D'};

%% loop over participants
for pp = [1];

    %% load epoched data of this participant data
    param = getSubjParam(pp);
    col_data = load([param.path, '\epoched_data\eyedata_m5', '__', param.subjName, '_c'], 'eyedata');
    dur_data = load([param.path, '\epoched_data\eyedata_m5', '__', param.subjName, '_d'], 'eyedata');
    
    col_data = col_data.eyedata;
    dur_data = dur_data.eyedata;

    %% only keep channels of interest
    cfg = [];
    cfg.channel = {'eyeX','eyeY'}; % only keep x & y axis
    
    col_data = ft_selectdata(cfg, col_data); % select x & y channels for colour data
    dur_data = ft_selectdata(cfg, dur_data); % select x & y channels for duration data

    %% reformat all data to a single matrix of trial x channel x time
    cfg = [];
    cfg.keeptrials = 'yes';
    
    tl_col = ft_timelockanalysis(cfg, col_data); % realign the data: from trial*time cells into trial*channel*time?
    tl_col.time = tl_col.time * 1000;
    
    tl_dur = ft_timelockanalysis(cfg, dur_data); % realign the data: from trial*time cells into trial*channel*time?
    tl_dur.time = tl_dur.time * 1000;

    %% pixel to degree
    [dva_x, dva_y] = frevede_pixel2dva(squeeze(tl_col.trial(:,1,:)), squeeze(tl_col.trial(:,2,:)));
    tl_col.trial(:,1,:) = dva_x;
    tl_col.trial(:,2,:) = dva_y;

    [dva_x, dva_y] = frevede_pixel2dva(squeeze(tl_dur.trial(:,1,:)), squeeze(tl_dur.trial(:,2,:)));
    tl_dur.trial(:,1,:) = dva_x;
    tl_dur.trial(:,2,:) = dva_y;

    %% selection vectors for conditions -- this is where it starts to become interesting!
    % COLOUR
    % where was target item located (and therefore where does the cue "point")
    c_cueL = ismember(tl_col.trialinfo(:,1), [31:38]);
    c_cueR = ismember(tl_col.trialinfo(:,1), [39,310:316]);
      
    % which order was the cued item
    c_targ1 = ismember(tl_col.trialinfo(:,1), [31,33,35,37,39,311,313,315]);
    c_targ2 = ismember(tl_col.trialinfo(:,1), [32,34,36,38,310,312,314,316]);
    
    % which item was short or long
    c_short_targ = ismember(tl_col.trialinfo(:,1), [31:34, 39,310:312]);
    c_long_targ = ismember(tl_col.trialinfo(:,1), [35:38, 313:316]);

    % congruency
    c_congruent = ismember(tl_col.trialinfo(:,1), [31:32, 35:36, 39,310, 313:314]);
    c_incongruent = ismember(tl_col.trialinfo(:,1), [33:34, 37:38, 311:312, 315:316]);

    % channels
    c_chX = ismember(tl_col.label, 'eyeX');
    c_chY = ismember(tl_col.label, 'eyeY');

    % DURATION
    % where was target item located (and therefore where does the cue "point")
    d_cueL = ismember(tl_dur.trialinfo(:,1), [317:324]);
    d_cueR = ismember(tl_dur.trialinfo(:,1), [325:332]);
      
    % which order was the cued item
    d_targ1 = ismember(tl_dur.trialinfo(:,1), [317,319,321,323,325,327,329,331]);
    d_targ2 = ismember(tl_dur.trialinfo(:,1), [318,320,322,324,326,328,330,332]);
    
    % which item was short or long
    d_short_targ = ismember(tl_dur.trialinfo(:,1), [317:320,325:328]);
    d_long_targ = ismember(tl_dur.trialinfo(:,1), [321:324,329:332]);

    % congruency
    d_congruent = ismember(tl_dur.trialinfo(:,1), [317:318, 321:322, 325:326, 329:330]);
    d_incongruent = ismember(tl_dur.trialinfo(:,1), [319:320, 323:324, 327:328, 331:332]);

    % channels
    d_chX = ismember(tl_dur.label, 'eyeX');
    d_chY = ismember(tl_dur.label, 'eyeY');

    %% get gaze shifts using our custom function
    cfg = [];
    
    data_input = squeeze(tl_col.trial);
    time_input = tl_col.time;
    [c_shiftsX, c_shiftsY, c_peakvelocity, c_times] = PBlab_gazepos2shift_2D(cfg, data_input(:,c_chX,:), data_input(:,c_chY,:), time_input);

    data_input = squeeze(tl_dur.trial);
    time_input = tl_dur.time;
    [d_shiftsX, d_shiftsY, d_peakvelocity, d_times] = PBlab_gazepos2shift_2D(cfg, data_input(:,d_chX,:), data_input(:,d_chY,:), time_input);

    %% select usable gaze shifts
    minDisplacement = 0;
    maxDisplacement = 1000;

    if oneOrTwoD == 1
        c_saccadesize = abs(c_shiftsX);
        d_saccadesize = abs(d_shiftsX);
    elseif oneOrTwoD == 2
        c_saccadesize = abs(c_shiftsX+c_shiftsY*1i);
        d_saccadesize = abs(d_shiftsX+d_shiftsY*1i);
    end

    c_shiftsL = c_shiftsX<0 & (c_saccadesize>minDisplacement & c_saccadesize<maxDisplacement);
    c_shiftsR = c_shiftsX>0 & (c_saccadesize>minDisplacement & c_saccadesize<maxDisplacement);

    d_shiftsL = d_shiftsX<0 & (d_saccadesize>minDisplacement & d_saccadesize<maxDisplacement);
    d_shiftsR = d_shiftsX>0 & (d_saccadesize>minDisplacement & d_saccadesize<maxDisplacement);

    %% get relevant contrasts out
    saccade = [];
    if c_times == d_times
        saccade.time = c_times;
    else
        throw('Times between the two different tasks are suddenly different!')
    end
    sel = ones(size(c_cueL)); %NB: selection of oktrials has happened at the start when remove_unfixated is "on".
    saccade.label = {'colour_all', 'colour_targ1', 'colour_targ2', 'colour_short', 'colour_long', 'colour_congruent', 'colour_incongruent',...
    'duration_all', 'duration_targ1', 'duration_targ2', 'duration_short', 'duration_long', 'duration_congruent', 'duration_incongruent'};

    for selection = [1:7] % colour conditions
        if     selection == 1  sel = ones(size(c_cueL));
        elseif selection == 2  sel = c_targ1;
        elseif selection == 3  sel = c_targ2;
        elseif selection == 4  sel = c_short_targ;
        elseif selection == 5  sel = c_long_targ;
        elseif selection == 6  sel = c_congruent;
        elseif selection == 7  sel = c_incongruent;
        end

        saccade.toward(selection,:) =  (mean(c_shiftsL(c_cueL&sel,:)) + mean(c_shiftsR(c_cueR&sel,:))) ./ 2;
        saccade.away(selection,:)  =   (mean(c_shiftsL(c_cueR&sel,:)) + mean(c_shiftsR(c_cueL&sel,:))) ./ 2;
    end
    
    for selection = [8:14] % duration conditions
        if     selection == 8  sel = ones(size(d_cueL));
        elseif selection == 9  sel = d_targ1;
        elseif selection == 10  sel = d_targ2;
        elseif selection == 11  sel = d_short_targ;
        elseif selection == 12  sel = d_long_targ;
        elseif selection == 13  sel = d_congruent;
        elseif selection == 14  sel = d_incongruent;
        end

        saccade.toward(selection,:) =  (mean(d_shiftsL(d_cueL&sel,:)) + mean(d_shiftsR(d_cueR&sel,:))) ./ 2;
        saccade.away(selection,:)  =   (mean(d_shiftsL(d_cueR&sel,:)) + mean(d_shiftsR(d_cueL&sel,:))) ./ 2;
    end

    % add towardness field
    saccade.effect = (saccade.toward - saccade.away);
    
    %% smooth and turn to Hz
    integrationwindow = 100; % window over which to integrate saccade counts
    
    saccade.toward = smoothdata(saccade.toward,2,'movmean',integrationwindow)*1000; % *1000 to get to Hz, given 1000 samples per second.
    saccade.away   = smoothdata(saccade.away,2,  'movmean',integrationwindow)*1000;
    saccade.effect = smoothdata(saccade.effect,2,'movmean',integrationwindow)*1000;

    %% also get as function of saccade size - identical as above, except with extra loop over saccade size.
    binsize = 0.5;
    halfbin = binsize/2;

    saccadesize = [];
    saccadesize.dimord = 'chan_freq_time';
    saccadesize.freq = halfbin:0.1:7-halfbin; % shift sizes, as if "frequency axis" for time-frequency plot
    saccadesize.time = c_times; %no need to check here, since we already checked above whether d_times is the same
    saccadesize.label = saccade.label;

    c = 0;
    for sz = saccadesize.freq;
        c = c+1;
        
        c_shiftsL = []; c_shiftsR = [];
        d_shiftsL = []; d_shiftsR = [];
        
        c_shiftsL = c_shiftsX<-sz+halfbin & c_shiftsX > -sz-halfbin; % left shifts within this range
        c_shiftsR = c_shiftsX>sz-halfbin  & c_shiftsX < sz+halfbin; % right shifts within this range
        
        d_shiftsL = d_shiftsX<-sz+halfbin & d_shiftsX > -sz-halfbin; % left shifts within this range
        d_shiftsR = d_shiftsX>sz-halfbin  & d_shiftsX < sz+halfbin; % right shifts within this range

        for selection = [1:7] % colour conditions
            if     selection == 1  sel = ones(size(c_cueL));
            elseif selection == 2  sel = c_targ1;
            elseif selection == 3  sel = c_targ2;
            elseif selection == 4  sel = c_short_targ;
            elseif selection == 5  sel = c_long_targ;
            elseif selection == 6  sel = c_congruent;
            elseif selection == 7  sel = c_incongruent;
            end

            saccadesize.toward(selection,c,:) =  (mean(c_shiftsL(c_cueL&sel,:)) + mean(c_shiftsR(c_cueR&sel,:))) ./ 2;
            saccadesize.away(selection,c,:)  =   (mean(c_shiftsL(c_cueR&sel,:)) + mean(c_shiftsR(c_cueL&sel,:))) ./ 2;
        end

        for selection = [8:14] % duration conditions
            if     selection == 8  sel = ones(size(d_cueL));
            elseif selection == 9  sel = d_targ1;
            elseif selection == 10  sel = d_targ2;
            elseif selection == 11  sel = d_short_targ;
            elseif selection == 12  sel = d_long_targ;
            elseif selection == 13  sel = d_congruent;
            elseif selection == 14  sel = d_incongruent;
            end

            saccadesize.toward(selection,c,:) =  (mean(d_shiftsL(d_cueL&sel,:)) + mean(d_shiftsR(d_cueR&sel,:))) ./ 2;
            saccadesize.away(selection,c,:)  =   (mean(d_shiftsL(d_cueR&sel,:)) + mean(d_shiftsR(d_cueL&sel,:))) ./ 2;
        end

    end
   
    % add towardness field
    saccadesize.effect = (saccadesize.toward - saccadesize.away);

    %% smooth and turn to Hz
    integrationwindow = 100; % window over which to integrate saccade counts
    saccadesize.toward = smoothdata(saccadesize.toward,3,'movmean',integrationwindow)*1000; % *1000 to get to Hz, given 1000 samples per second.
    saccadesize.away   = smoothdata(saccadesize.away,3,  'movmean',integrationwindow)*1000;
    saccadesize.effect = smoothdata(saccadesize.effect,3,'movmean',integrationwindow)*1000;

    %% save
    save([param.path, '\saved_data\saccadeEffects', oneOrTwoD_options{oneOrTwoD} '__', param.subjName], 'saccade','saccadesize');
    %% close loops
end % end pp loop