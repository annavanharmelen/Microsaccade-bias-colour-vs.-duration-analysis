%% Step2--Gaze position calculation

%% start clean
clear; clc; close all;

%% parameters
baselineCorrect     = 0; 
removeTrials        = 0; % remove trials where gaze deviation larger than value specified below. Only sensible after baseline correction!
max_eye_pos         = 2; % remove trials with x_position bigger than 2 degrees visual angle

plotResults         = 0;


for pp = [1:25];

    %% load epoched data of this participant
    param = getSubjParam(pp);
    col_data = load([param.path, '\epoched_data\eyedata_m5', '__', param.subjName, '_c'], 'eyedata');
    dur_data = load([param.path, '\epoched_data\eyedata_m5', '__', param.subjName, '_d'], 'eyedata');
    
    col_data = col_data.eyedata;
    dur_data = dur_data.eyedata;

    %% only keep channels of interest
    cfg = [];
    cfg.channel = {'eyeX','eyeY'}; % only keep x & y axis

    col_data = ft_selectdata(cfg, col_data); % select x & y channels for colour data
    dur_data = ft_selectdata(cfg, dur_data); % select x & y channels for duration da
    
    %% reformat all data to a single matrix of trial x channel x time
    cfg = [];
    cfg.keeptrials = 'yes';
    
    tl_col = ft_timelockanalysis(cfg, col_data); % realign the data: from trial*time cells into trial*channel*time?
    tl_col.time = tl_col.time * 1000;
    
    tl_dur = ft_timelockanalysis(cfg, dur_data); % realign the data: from trial*time cells into trial*channel*time?
    tl_dur.time = tl_dur.time * 1000;
    
    % dirty hack to get proxy for blink rate
    tl_col.blink = squeeze(isnan(tl_col.trial(:,1,:))*100); % 0 where not nan, 1 where nan (putative blink, or eye close etc.)... *100 to get to percentage of trials where blink at that time
    tl_dur.blink = squeeze(isnan(tl_dur.trial(:,1,:))*100); % 0 where not nan, 1 where nan (putative blink, or eye close etc.)... *100 to get to percentage of trials where blink at that time
    
    %% baseline correct?
    if baselineCorrect
        tsel_col = tl_col.time >= -250 & tl_col.time <= 0; 
        tsel_dur = tl_dur.time >= -250 & tl_dur.time <= 0; 

        bl = squeeze(mean(tl_col.trial(:,:,tsel),3));
        for t = 1:length(tl_col.time)
            tl_col.trial(:,:,t) = ((tl_col.trial(:,:,t) - bl));
        end

        bl = squeeze(mean(tl_dur.trial(:,:,tsel),3));
        for t = 1:length(tl_dur.time)
            tl_dur.trial(:,:,t) = ((tl_dur.trial(:,:,t) - bl));
        end
    end
    
    %% pixel to degree
    [dva_x, dva_y] = frevede_pixel2dva(squeeze(tl_col.trial(:,1,:)), squeeze(tl_col.trial(:,2,:)));
    tl_col.trial(:,1,:) = dva_x;
    tl_col.trial(:,2,:) = dva_y;

    [dva_x, dva_y] = frevede_pixel2dva(squeeze(tl_dur.trial(:,1,:)), squeeze(tl_dur.trial(:,2,:)));
    tl_dur.trial(:,1,:) = dva_x;
    tl_dur.trial(:,2,:) = dva_y;
    
    %% remove trials with gaze deviation >= 2 dva
    chX_c = ismember(tl_col.label, 'eyeX');
    chY_c = ismember(tl_col.label, 'eyeY');

    chX_d = ismember(tl_dur.label, 'eyeX');
    chY_d = ismember(tl_dur.label, 'eyeY');
    
    if plotResults
        figure;
        plot(tl_col.time, squeeze(tl_col.trial(:,chX_c,:)));
        title('all trials - full time range');

        figure;
        plot(tl_dur.time, squeeze(tl_dur.trial(:,chX_d,:)));
        title('all trials - full time range');
    end
    
    if removeTrials
        % first colour
        tsel = tl_col.time>= 0 & tl_col.time <=3000; % only check within this time range of interest
        
        figure;
        subplot(1,2,1);
        plot(tl_col.time(tsel), squeeze(tl_col.trial(:,chX_c,tsel)));
        title('before');
        
        for trl = 1:size(tl_col.trial,1)
            oktrial(trl) = sum(sqrt(abs(tl_col.trial(trl,chX_c,tsel)).^2 + abs(tl_col.trial(trl,chY_c,tsel)).^2  ) > max_eye_pos) ==0;
        end
        tl_col.trial = tl_col.trial(oktrial,:,:);
        tl_col.trialinfo = tl_col.trialinfo(oktrial,:);
    
        subplot(1,2,2);
        plot(tl_col.time(tsel), squeeze(tl_col.trial(:,chX_c,tsel)));
        title('after');
        proportionOK(pp) = mean(oktrial)*100;
        fprintf('%s has %.2f%% OK trials - COLOUR\n\n', param.subjName, mean(oktrial)*100)
        
        % then duration
        tsel = tl_dur.time>= 0 & tl_dur.time <=3000; % only check within this time range of interest
        
        figure;
        subplot(1,2,1);
        plot(tl_dur.time(tsel), squeeze(tl_dur.trial(:,chX_d,tsel)));
        title('before');
        
        for trl = 1:size(tl_dur.trial,1)
            oktrial(trl) = sum(sqrt(abs(tl_dur.trial(trl,chX_d,tsel)).^2 + abs(tl_dur.trial(trl,chY_d,tsel)).^2  ) > max_eye_pos) ==0;
        end
        tl_dur.trial = tl_dur.trial(oktrial,:,:);
        tl_dur.trialinfo = tl_dur.trialinfo(oktrial,:);
    
        subplot(1,2,2);
        plot(tl_dur.time(tsel), squeeze(tl_dur.trial(:,chX_d,tsel)));
        title('after');
        proportionOK(pp) = mean(oktrial)*100;
        fprintf('%s has %.2f%% OK trials - DURATION\n\n', param.subjName, mean(oktrial)*100)
    end
    
    %% selection vectors for conditions -- this is where it starts to become interesting!
    % COLOUR
    % where was target item located (and therefore where does the cue "point")
    c_cueL = ismember(tl_col.trialinfo(:,1), [31,32,33,34]);
    c_cueR = ismember(tl_col.trialinfo(:,1), [35,36,37,38]);
      
    % which order was the cued item
    c_targ1 = ismember(tl_col.trialinfo(:,1), [31,33,35,37]);
    c_targ2 = ismember(tl_col.trialinfo(:,1), [32,34,36,38]);
    
    % which item was short or long
    c_short_targ = ismember(tl_col.trialinfo(:,1), [31,32,35,36]);
    c_long_targ = ismember(tl_col.trialinfo(:,1), [33,34,37,38]);

    % DURATION
    % where was target item located (and therefore where does the cue "point")
    d_cueL = ismember(tl_dur.trialinfo(:,1), [39,310,311,312]);
    d_cueR = ismember(tl_dur.trialinfo(:,1), [313,314,315,316]);
      
    % which order was the cued item
    d_targ1 = ismember(tl_dur.trialinfo(:,1), [39,311,313,315]);
    d_targ2 = ismember(tl_dur.trialinfo(:,1), [310,312,314,316]);
    
    % which item was short or long
    d_short_targ = ismember(tl_dur.trialinfo(:,1), [39,310,313,314]);
    d_long_targ = ismember(tl_dur.trialinfo(:,1), [311,312,315,316]);

    %% get relevant contrasts out
    gaze = [];
    if tl_col.time == tl_dur.time
        gaze.time = tl_col.time;
    else
        throw('Times between the two different tasks are suddenly different!')
    end
    gaze.label = {'colour_all', 'colour_targ1', 'colour_targ2', 'colour_short', 'colour_long', ...
    'duration_all', 'duration_targ1', 'duration_targ2', 'duration_short', 'duration_long'};

    for selection = [1:5] % colour conditions
        if     selection == 1  sel = ones(size(c_cueL));
        elseif selection == 2  sel = c_targ1;
        elseif selection == 3  sel = c_targ2;
        elseif selection == 4  sel = c_short_targ;
        elseif selection == 5  sel = c_long_targ;
        end

        gaze.dataL(selection,:) = squeeze(nanmean(tl_col.trial(sel&c_cueL, chX_c,:)));
        gaze.dataR(selection,:) = squeeze(nanmean(tl_col.trial(sel&c_cueR, chX_c,:)));
        gaze.blinkrate(selection,:) = squeeze(nanmean(tl_col.blink(sel, :)));
    end

    for selection = [6:10] % duration conditions
        if     selection == 6  sel = ones(size(d_cueL));
        elseif selection == 7  sel = d_targ1;
        elseif selection == 8  sel = d_targ2;
        elseif selection == 9  sel = d_short_targ;
        elseif selection == 10  sel = d_long_targ;
        end

        gaze.dataL(selection,:) = squeeze(nanmean(tl_dur.trial(sel&d_cueL, chX_d,:)));
        gaze.dataR(selection,:) = squeeze(nanmean(tl_dur.trial(sel&d_cueR, chX_d,:)));
        gaze.blinkrate(selection,:) = squeeze(nanmean(tl_dur.blink(sel, :)));
    end

    % add towardness field
    gaze.towardness = (gaze.dataR - gaze.dataL) ./ 2;
    
    %% save
    if baselineCorrect == 1     toadd1 = '_baselineCorrect';    else toadd1 = ''; end % depending on this option, append to name of saved file.    
    if removeTrials == 1        toadd2 = '_removeTrials';       else toadd2 = ''; end % depending on this option, append to name of saved file.    
    
    save([param.path, '\saved_data\gazePositionEffects', toadd1, toadd2, '__', param.subjName], 'gaze');
    
    drawnow; 

%% close loops
end % end pp loop


