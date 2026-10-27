clear all
close all
clc

%% set parameters and loops
display_percentage_ok = 1;
plot_individuals = 1;
plot_averages = 1;

pp2do = [1];
p = 0;

bin_edges = -180:10:180;
bin_centres = -175:10:175;

subplot_size = 1;

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
    c_oktrials = abs(zscore(colour_data.reaction_time_in_ms))<=3;
    d_oktrials = abs(zscore(duration_data.reaction_time_in_ms))<=3;

    % display both data types per person together
    percentageok(p,1) = mean([mean(c_oktrials), mean(d_oktrials)])*100;
    percentageok(p,2) = mean(c_oktrials)*100;
    percentageok(p,3) = mean(d_oktrials)*100;
  
    % display percentage unbroken trials
    if display_percentage_ok
        fprintf('%s has %.2f%% OK colour trials and %.2f%% OK duration trials\n\n', param.subjName, percentageok(p,2), percentageok(p,3))
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

    target_colours = str2double(erase(colour_data.target_colour,["[", ", 0.2, 0.5]"]));
    distractor_colours = str2double(erase(colour_data.distractor_colour,["[", ", 0.2, 0.5]"]));

    %% extract data of interest
    c_overall_rt(p,1) = mean(colour_data.reaction_time_in_ms(c_oktrials), "omitnan"); 
    c_accuracy(p,1) = sum(colour_data.correct_response(c_oktrials) == "True")/size(colour_data(c_oktrials,:),1);

    c_average_of_both(p,1) = mean(mean(str2double(split(erase(erase(colour_data.stimuli_colours, ["[[", ", 0.2, 0.5]", " [", ", 0.2, 0.5]]"]), "]"), ",")), 2));
    temp = str2double(split(erase(erase(colour_data.stimuli_colours, ["[[", ", 0.2, 0.5]", " [", ", 0.2, 0.5]]"]), "]"), ","));
    temp = abs(temp(:,1) - temp(:,2));
    temp(temp > 180) = 360 - temp(temp > 180);
    c_difference_between_both(p,1) = mean(temp);
    
    % get behavioural data as function of target_order
    order_labels = {'cue1', 'cue2'};
    
    c_rt_order(p,1) = mean(colour_data.reaction_time_in_ms(first_target_trials&c_oktrials), "omitnan");
    c_rt_order(p,2) = mean(colour_data.reaction_time_in_ms(second_target_trials&c_oktrials), "omitnan");
    
    c_accuracy_order(p,1) = sum(colour_data.correct_response(first_target_trials&c_oktrials) == "True")/size(colour_data(first_target_trials&c_oktrials,:),1);
    c_accuracy_order(p,2) = sum(colour_data.correct_response(second_target_trials&c_oktrials) == "True")/size(colour_data(second_target_trials&c_oktrials,:),1);
    
    % get behavioural data as function of target duration
    duration_labels = {'short', 'long'};

    c_rt_duration(p,1) = mean(colour_data.reaction_time_in_ms(short_target_trials&c_oktrials), "omitnan");
    c_rt_duration(p,2) = mean(colour_data.reaction_time_in_ms(long_target_trials&c_oktrials), "omitnan");
    
    c_accuracy_duration(p,1) = sum(colour_data.correct_response(short_target_trials&c_oktrials) == "True")/size(colour_data(short_target_trials&c_oktrials,:),1);
    c_accuracy_duration(p,2) = sum(colour_data.correct_response(long_target_trials&c_oktrials) == "True")/size(colour_data(long_target_trials&c_oktrials,:),1);

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
    d_overall_rt(p,1) = mean(duration_data.reaction_time_in_ms(d_oktrials), "omitnan");
    d_accuracy(p,1) = sum(duration_data.correct_response(d_oktrials) == "True")/size(duration_data(d_oktrials,:),1);
    
    d_average_of_both(p,1) = mean(mean(str2double(split(erase(duration_data.durations, ["["," ","]"]), ",")), 2));
    temp = str2double(split(erase(duration_data.durations, ["["," ","]"]), ","));
    d_difference_between_both(p,1) = mean(abs(temp(:,1) - temp(:,2)));
    
    % get behavioural data as function of target_order    
    d_rt_order(p,1) = mean(duration_data.reaction_time_in_ms(first_target_trials&d_oktrials), "omitnan");
    d_rt_order(p,2) = mean(duration_data.reaction_time_in_ms(second_target_trials&d_oktrials), "omitnan");
    
    d_accuracy_order(p,1) = sum(duration_data.correct_response(first_target_trials&d_oktrials) == "True")/size(duration_data(first_target_trials&d_oktrials,:),1);
    d_accuracy_order(p,2) = sum(duration_data.correct_response(second_target_trials&d_oktrials) == "True")/size(duration_data(second_target_trials&d_oktrials,:),1);
    
    % get behavioural data as function of target duration
    d_rt_duration(p,1) = mean(duration_data.reaction_time_in_ms(short_target_trials&d_oktrials), "omitnan");
    d_rt_duration(p,2) = mean(duration_data.reaction_time_in_ms(long_target_trials&d_oktrials), "omitnan");
    
    d_accuracy_duration(p,1) = sum(duration_data.correct_response(short_target_trials&d_oktrials) == "True")/size(duration_data(short_target_trials&d_oktrials,:),1);
    d_accuracy_duration(p,2) = sum(duration_data.correct_response(long_target_trials&d_oktrials) == "True")/size(duration_data(long_target_trials&d_oktrials,:),1);

    %% basic data checks, each pp in own subplot
    if plot_individuals
        figure(fig_nr);
        fig_nr = fig_nr+1;
        subplot(subplot_size,subplot_size,p);
        h = histogram(colour_data.reaction_time_in_ms,50);
        title(['decision time - colour pp', num2str(pp2do(p))]);
        ylim([0 200]);

        figure(fig_nr);
        fig_nr = fig_nr+1;
        subplot(subplot_size,subplot_size,p);
        h = histogram(duration_data.reaction_time_in_ms,50);
        title(['decision time - duration pp', num2str(pp2do(p))]);
        ylim([0 200]);

        figure(fig_nr);
        fig_nr = fig_nr+1;
        subplot(subplot_size,subplot_size,p);
        bar(c_accuracy);       
        title(['colour accuracy - pp', num2str(pp2do(p))]);

        
        figure(fig_nr);
        fig_nr = fig_nr+1;
        subplot(subplot_size,subplot_size,p);
        bar(d_accuracy);
        title(['duration accuracy - pp', num2str(pp2do(p))]);
    end

    %% get behavioural effect as function of target duration
    % bin stimulus durations
    target_duration_bins = 200:100:1800;
    
    % colour
    i = 0;
    for target_duration = target_duration_bins
        i = i + 1;
        trial_sel = colour_data.target_duration < target_duration+50 & colour_data.target_duration > target_duration-50;

        c_rt_durations(p,i) = mean(colour_data.reaction_time_in_ms(trial_sel&c_oktrials), "omitnan");
        c_accuracy_durations(p,i) = sum(colour_data.correct_response(trial_sel&c_oktrials) == "True")/size(colour_data(trial_sel&c_oktrials,:),1);
    end
    
    % duration
    i = 0;
    for target_duration = target_duration_bins
        i = i + 1;
        trial_sel = duration_data.target_duration < target_duration+50 & duration_data.target_duration > target_duration-50;

        d_rt_durations(p,i) = mean(duration_data.reaction_time_in_ms(trial_sel&d_oktrials), "omitnan");
        d_accuracy_durations(p,i) = sum(duration_data.correct_response(trial_sel&d_oktrials) == "True")/size(duration_data(trial_sel&d_oktrials,:),1);
    end
end

if plot_averages
 %% check performance
    figure(fig_nr);
    fig_nr = fig_nr+1;
    subplot(2,2,1);
    bar(ppnum, c_overall_rt(:,1));
    title('COLOUR overall reaction time');
    ylim([0, 3000]);
    xlabel('pp #');

    subplot(2,2,3);
    bar(ppnum, c_accuracy(:,1));
    title('overall accuracy');
    ylim([0,1]);
    xlabel('pp #');
    
    subplot(2,2,2);
    bar(ppnum, d_overall_rt(:,1));
    title('DURATION overall reaction time');
    ylim([0, 3000]);
    xlabel('pp #');

    subplot(2,2,4);
    bar(ppnum, d_accuracy(:,1));
    title('overall accuracy');
    ylim([0,1]);
    xlabel('pp #');

    %% effect of target duration on behaviour
    figure(fig_nr);
    fig_nr = fig_nr+1;
    
    subplot(2,2,1);
    hold on
    title('COLOUR - decision time');
    bar(duration_labels, mean(c_rt_duration));
    errorbar([1:2], [mean(c_rt_duration)], [std(c_rt_duration) ./ sqrt(size(pp2do,2))], 'LineStyle', 'none', 'Color', 'k');

    subplot(2,2,3);
    hold on
    title('COLOUR - error');
    bar(duration_labels, mean(c_accuracy_duration));
    errorbar([1:2], [mean(c_accuracy_duration)], [std(c_accuracy_duration) ./ sqrt(size(pp2do,2))], 'LineStyle', 'none', 'Color', 'k');

    subplot(2,2,2);
    hold on
    title('DURATION - decision time');
    bar(duration_labels, mean(d_rt_duration));
    errorbar([1:2], [mean(d_rt_duration)], [std(d_rt_duration) ./ sqrt(size(pp2do,2))], 'LineStyle', 'none', 'Color', 'k');

    subplot(2,2,4);
    hold on
    title('DURATION - error');
    bar(duration_labels, mean(d_accuracy_duration));
    errorbar([1:2], [mean(d_accuracy_duration)], [std(d_accuracy_duration) ./ sqrt(size(pp2do,2))], 'LineStyle', 'none', 'Color', 'k');

    %% accuracy per task: colour vs. duration
    figure;
    subplot(1,2,1)
    bar(mean(c_accuracy));
    std(std(c_accuracy));
    xlim([1, 2]);
    ylim([0, 1]);
    title('Colour');

    subplot(1,2,2)
    bar(mean(d_accuracy));
    std(std(d_accuracy));
    xlim([1, 2]);
    ylim([0, 1]);
    title('Duration');

end