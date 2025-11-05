clear all
close all
clc

%% set parameters and loops
display_percentage_ok = 1;
plot_individuals = 1;
plot_averages = 1;

pp2do = [1:4];
p = 0;

bin_edges = -180:10:180;
bin_centres = -175:10:175;

subplot_size = 2;

for pp = pp2do
    p = p+1;
    ppnum(p) = pp;
    fig_nr = 1;
    
    param = getSubjParam(pp);
    disp(['getting data from ', param.subjName]);
    
    %% load actual behavioural data
    colour_data = readtable(param.colour_beh);
    duration_data = readtable(param.duration_beh);

    %% check percentage oktrials
    % select trials with reasonable decision times from both datasets
    c_oktrials = abs(zscore(colour_data.idle_reaction_time_in_ms))<=3;
    d_oktrials = abs(zscore(duration_data.idle_reaction_time_in_ms))<=3;

    % display both data types per person together
    percentageok(p,1) = mean([mean(c_oktrials), mean(d_oktrials)])*100;
  
    % display percentage unbroken trials
    if display_percentage_ok
        fprintf('%s has %.2f%% OK trials\n\n', param.subjName, percentageok(p,1))
    end
    %% basic data checks, each pp in own subplot
    if plot_individuals
        figure(fig_nr);
        fig_nr = fig_nr+1;
        subplot(subplot_size,subplot_size,p);
        h = histogram(colour_data.idle_reaction_time_in_ms,50);
        title(['decision time - colour pp', num2str(pp2do(p))]);
        ylim([0 200]);

        figure(fig_nr);
        fig_nr = fig_nr+1;
        subplot(subplot_size,subplot_size,p);
        h = histogram(duration_data.idle_reaction_time_in_ms,50);
        title(['decision time - duration pp', num2str(pp2do(p))]);
        ylim([0 200]);

        figure(fig_nr);
        fig_nr = fig_nr+1;
        subplot(subplot_size,subplot_size,p);
        h = histogram(colour_data.response_time_in_ms, 50);
        title(['response time - colour pp', num2str(pp2do(p))]);
        xlim([0 5010]);
        ylim([0 150]);

        figure(fig_nr);
        fig_nr = fig_nr+1;
        subplot(subplot_size,subplot_size,p);
        h = histogram(duration_data.response_time_in_ms, 50);
        title(['response time - duration pp', num2str(pp2do(p))]);
        xlim([0 5010]);
        ylim([0 150]);
        
        figure(fig_nr);
        fig_nr = fig_nr+1;
        subplot(subplot_size,subplot_size,p);
        h = histogram(colour_data.abs_rgb_distance,50);       
        title(['colour error abs - pp', num2str(pp2do(p))]);

        
        figure(fig_nr);
        fig_nr = fig_nr+1;
        subplot(subplot_size,subplot_size,p);
        h = histogram(duration_data.duration_diff_abs,50);     
        title(['duration error abs - pp', num2str(pp2do(p))]);
    end

    %% %%%% COLOUR DATA EXTRACTION %%%%

    %% colour trial selections
    left_trials = ismember(colour_data.target_position, {'left'});
    right_trials = ismember(colour_data.target_position, {'right'});

    first_target_trials = colour_data.target_number == 1;
    second_target_trials = colour_data.target_number == 2;

    short_target_trials = ismember(colour_data.target_duration_cat, {'short'});
    long_target_trials = ismember(colour_data.target_duration_cat, {'long'});

    premature_trials = ismember(colour_data.premature_pressed, {'True'});

    %% get pushpull necessary data
    target_colours = str2double(erase(colour_data.target_colour,["[", ", 0.2, 0.5]"]));
    distractor_colours = str2double(erase(colour_data.distractor_colour,["[", ", 0.2, 0.5]"]));
    response_colours = str2double(erase(colour_data.selected_colour,["[", ", 0.2, 0.5]"]));

    target_colour_diff = (mod(distractor_colours - target_colours + 180, 360) - 180)';
    response_colour_diff = (mod(response_colours - target_colours + 180, 360) - 180)';

    % bin data to save
    [target_colour_diff_binned(p,:),~,bin] = histcounts(target_colour_diff, bin_edges);
    response_colour_diff_binned(p,:) = accumarray(bin', response_colour_diff', [size(bin_centres,2) 1], @mean);

    % also get colour responses clustered
    colour_responses(p,:) = histcounts(str2double(erase(colour_data.selected_colour,["[", ", 0.2, 0.5]"])), 360);
    
    %% extract data of interest
    c_overall_dt(p,1) = mean(colour_data.idle_reaction_time_in_ms(c_oktrials), "omitnan");
    c_overall_rt(p,1) = mean(colour_data.response_time_in_ms(c_oktrials), "omitnan");
    c_overall_total_rt(p,1) = mean(colour_data.idle_reaction_time_in_ms(c_oktrials), "omitnan") + mean(colour_data.response_time_in_ms(c_oktrials), "omitnan");
    c_overall_abs_error(p,1) = mean(colour_data.abs_rgb_distance(c_oktrials), "omitnan");
    c_overall_error_signed(p,1) = mean(colour_data.rgb_distance_signed(c_oktrials), "omitnan");
    
    % get behavioural data as function of target_order
    order_labels = {'cue1', 'cue2'};
    
    c_dt_order(p,1) = mean(colour_data.idle_reaction_time_in_ms(first_target_trials&c_oktrials), "omitnan");
    c_dt_order(p,2) = mean(colour_data.idle_reaction_time_in_ms(second_target_trials&c_oktrials), "omitnan");
    
    c_rt_order(p,1) = mean(colour_data.response_time_in_ms(first_target_trials&c_oktrials), "omitnan");
    c_rt_order(p,2) = mean(colour_data.response_time_in_ms(second_target_trials&c_oktrials), "omitnan");
    
    c_total_rt_order(p,1) = mean(colour_data.idle_reaction_time_in_ms(first_target_trials&c_oktrials), "omitnan") + mean(colour_data.response_time_in_ms(first_target_trials&c_oktrials), "omitnan");
    c_total_rt_order(p,2) = mean(colour_data.idle_reaction_time_in_ms(second_target_trials&c_oktrials), "omitnan") + mean(colour_data.response_time_in_ms(second_target_trials&c_oktrials), "omitnan");
    
    c_error_order(p,1) = mean(colour_data.abs_rgb_distance(first_target_trials&c_oktrials), "omitnan");
    c_error_order(p,2) = mean(colour_data.abs_rgb_distance(second_target_trials&c_oktrials), "omitnan");
    
    % get behavioural data as function of target duration
    duration_labels = {'short', 'long'};

    c_dt_duration(p,1) = mean(colour_data.idle_reaction_time_in_ms(short_target_trials&c_oktrials), "omitnan");
    c_dt_duration(p,2) = mean(colour_data.idle_reaction_time_in_ms(long_target_trials&c_oktrials), "omitnan");
    
    c_rt_duration(p,1) = mean(colour_data.response_time_in_ms(short_target_trials&c_oktrials), "omitnan");
    c_rt_duration(p,2) = mean(colour_data.response_time_in_ms(long_target_trials&c_oktrials), "omitnan");
    
    c_total_rt_duration(p,1) = mean(colour_data.idle_reaction_time_in_ms(short_target_trials&c_oktrials), "omitnan") + mean(colour_data.response_time_in_ms(short_target_trials&c_oktrials), "omitnan");
    c_total_rt_duration(p,2) = mean(colour_data.idle_reaction_time_in_ms(long_target_trials&c_oktrials), "omitnan") + mean(colour_data.response_time_in_ms(long_target_trials&c_oktrials), "omitnan");
    
    c_error_duration(p,1) = mean(colour_data.abs_rgb_distance(short_target_trials&c_oktrials), "omitnan");
    c_error_duration(p,2) = mean(colour_data.abs_rgb_distance(long_target_trials&c_oktrials), "omitnan");

    %% %%%% DURATION DATA EXTRACTION %%%%

    %% duration trial selections
    left_trials = ismember(duration_data.target_position, {'left'});
    right_trials = ismember(duration_data.target_position, {'right'});

    first_target_trials = duration_data.target_number == 1;
    second_target_trials = duration_data.target_number == 2;
    
    short_target_trials = ismember(duration_data.target_duration_cat, {'short'});
    long_target_trials = ismember(duration_data.target_duration_cat, {'long'});

    premature_trials = ismember(duration_data.premature_pressed, {'True'});

    %% extract data of interest
    d_overall_dt(p,1) = mean(duration_data.idle_reaction_time_in_ms(d_oktrials), "omitnan");
    d_overall_rt(p,1) = mean(duration_data.response_time_in_ms(d_oktrials), "omitnan");
    d_overall_total_rt(p,1) = mean(duration_data.idle_reaction_time_in_ms(d_oktrials), "omitnan") + mean(duration_data.response_time_in_ms(d_oktrials), "omitnan");
    d_overall_abs_error(p,1) = mean(duration_data.duration_diff_abs(d_oktrials), "omitnan");
    d_overall_error_signed(p,1) = mean(duration_data.duration_offset(d_oktrials), "omitnan");
    
    % get behavioural data as function of target_order    
    d_dt_order(p,1) = mean(duration_data.idle_reaction_time_in_ms(first_target_trials&d_oktrials), "omitnan");
    d_dt_order(p,2) = mean(duration_data.idle_reaction_time_in_ms(second_target_trials&d_oktrials), "omitnan");
    
    d_rt_order(p,1) = mean(duration_data.response_time_in_ms(first_target_trials&d_oktrials), "omitnan");
    d_rt_order(p,2) = mean(duration_data.response_time_in_ms(second_target_trials&d_oktrials), "omitnan");
    
    d_total_rt_order(p,1) = mean(duration_data.idle_reaction_time_in_ms(first_target_trials&d_oktrials), "omitnan") + mean(duration_data.response_time_in_ms(first_target_trials&d_oktrials), "omitnan");
    d_total_rt_order(p,2) = mean(duration_data.idle_reaction_time_in_ms(second_target_trials&d_oktrials), "omitnan") + mean(duration_data.response_time_in_ms(second_target_trials&d_oktrials), "omitnan");
    
    d_error_order(p,1) = mean(duration_data.duration_diff_abs(first_target_trials&d_oktrials), "omitnan");
    d_error_order(p,2) = mean(duration_data.duration_diff_abs(second_target_trials&d_oktrials), "omitnan");
    
    % get behavioural data as function of target duration
    d_dt_duration(p,1) = mean(duration_data.idle_reaction_time_in_ms(short_target_trials&d_oktrials), "omitnan");
    d_dt_duration(p,2) = mean(duration_data.idle_reaction_time_in_ms(long_target_trials&d_oktrials), "omitnan");
    
    d_rt_duration(p,1) = mean(duration_data.response_time_in_ms(short_target_trials&d_oktrials), "omitnan");
    d_rt_duration(p,2) = mean(duration_data.response_time_in_ms(long_target_trials&d_oktrials), "omitnan");
    
    d_total_rt_duration(p,1) = mean(duration_data.idle_reaction_time_in_ms(short_target_trials&d_oktrials), "omitnan") + mean(duration_data.response_time_in_ms(short_target_trials&d_oktrials), "omitnan");
    d_total_rt_duration(p,2) = mean(duration_data.idle_reaction_time_in_ms(long_target_trials&d_oktrials), "omitnan") + mean(duration_data.response_time_in_ms(long_target_trials&d_oktrials), "omitnan");
    
    d_error_duration(p,1) = mean(duration_data.duration_diff_abs(short_target_trials&d_oktrials), "omitnan");
    d_error_duration(p,2) = mean(duration_data.duration_diff_abs(long_target_trials&d_oktrials), "omitnan");  

    %% get behavioural effect as function of target duration
    % bin stimulus durations
    target_duration_bins = 200:100:1800;
    
    % colour
    i = 0;
    for target_duration = target_duration_bins
        i = i + 1;
        trial_sel = colour_data.target_duration < target_duration+50 & colour_data.target_duration > target_duration-50;

        c_dt_durations(p,i) = mean(colour_data.idle_reaction_time_in_ms(trial_sel&c_oktrials), "omitnan");
        c_rt_durations(p,i) = mean(colour_data.response_time_in_ms(trial_sel&c_oktrials), "omitnan");
        c_error_durations(p,i) = mean(colour_data.abs_rgb_distance(trial_sel&c_oktrials), "omitnan");
    end
    
    % duration
    i = 0;
    for target_duration = target_duration_bins
        i = i + 1;
        trial_sel = duration_data.target_duration < target_duration+50 & duration_data.target_duration > target_duration-50;

        d_dt_durations(p,i) = mean(duration_data.idle_reaction_time_in_ms(trial_sel&d_oktrials), "omitnan");
        d_rt_durations(p,i) = mean(duration_data.response_time_in_ms(trial_sel&d_oktrials), "omitnan");
        d_error_durations(p,i) = mean(duration_data.duration_diff_abs(trial_sel&d_oktrials), "omitnan");
    end
end

if plot_averages
 %% check performance
    figure(fig_nr);
    fig_nr = fig_nr+1;
    subplot(4,2,1);
    bar(ppnum, c_overall_dt(:,1));
    title('COLOUR overall decision time');
    ylim([0,1000]);
    xlabel('pp #');

    subplot(4,2,3);
    bar(ppnum, c_overall_rt(:,1));
    title('overall response time');
    ylim([0,4000]);
    xlabel('pp #');

    subplot(4,2,5);
    bar(ppnum, c_overall_abs_error(:,1));
    title('overall error');
    xlabel('pp #');

    subplot(4,2,7);
    hold on
    bar(ppnum, c_overall_error_signed(:,1));
    title('overall signed error');
    xlabel('pp #');
    
    subplot(4,2,2);
    bar(ppnum, d_overall_dt(:,1));
    title('DURATION overall decision time');
    ylim([0,1000]);
    xlabel('pp #');

    subplot(4,2,4);
    bar(ppnum, d_overall_rt(:,1));
    title('overall response time');
    ylim([0,4000]);
    xlabel('pp #');

    subplot(4,2,6);
    bar(ppnum, d_overall_abs_error(:,1));
    title('overall error');
    xlabel('pp #');

    subplot(4,2,8);
    hold on
    bar(ppnum, d_overall_error_signed(:,1));
    title('overall abs error');
    xlabel('pp #');

    %% effect of target duration on behaviour
    figure(fig_nr);
    fig_nr = fig_nr+1;
    
    subplot(2,2,1);
    hold on
    title('COLOUR - decision time');
    bar(duration_labels, mean(c_dt_duration));
    errorbar([1:2], [mean(c_dt_duration)], [std(c_dt_duration) ./ sqrt(size(pp2do,2))], 'LineStyle', 'none', 'Color', 'k');

    subplot(2,2,3);
    hold on
    title('COLOUR - error');
    bar(duration_labels, mean(c_error_duration));
    errorbar([1:2], [mean(c_error_duration)], [std(c_error_duration) ./ sqrt(size(pp2do,2))], 'LineStyle', 'none', 'Color', 'k');

    subplot(2,2,2);
    hold on
    title('DURATION - decision time');
    bar(duration_labels, mean(d_dt_duration));
    errorbar([1:2], [mean(d_dt_duration)], [std(d_dt_duration) ./ sqrt(size(pp2do,2))], 'LineStyle', 'none', 'Color', 'k');

    subplot(2,2,4);
    hold on
    title('DURATION - error');
    bar(duration_labels, mean(d_error_duration));
    errorbar([1:2], [mean(d_error_duration)], [std(d_error_duration) ./ sqrt(size(pp2do,2))], 'LineStyle', 'none', 'Color', 'k');

    %% investigate push-pull effect between the two items
    figure(fig_nr);
    fig_nr = fig_nr + 1;
    hold on
    frevede_errorbarplot(bin_centres, response_colour_diff_binned, 'k', 'se');
    plot(xlim, [0,0], 'k--');
    plot([0,0], ylim, 'k--');
    xlabel('Signed distance of non-target from target (°)')
    ylabel('Mean response error (°)');
    xlim([bin_centres(1), bin_centres(end)]);
    ylim([-15, 15]);

end