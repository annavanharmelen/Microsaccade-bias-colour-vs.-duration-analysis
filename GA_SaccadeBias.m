
%% Step3b--grand average plots of gaze-shift (saccade) results

%% start clean
clear; clc; close all;
    
%% parameters
oneOrTwoD       = 1;
oneOrTwoD_options = {'_1D','_2D'};

pp2do           = [2:25];

nsmooth         = 200;
plotSinglePps   = 0;
plotGAs         = 0;
plotFigures     = 0;
xlimtoplot      = [-100 1000];

pp_start_colour   = logical([1,0,1,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0]); 
pp_start_duration = logical([0,1,0,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1]); 

%% visual parameters
% todo
subplot_size = 5;

%% load and aggregate the data from all pp
s = 0;
for pp = pp2do
    s = s+1;

    % get participant data
    param = getSubjParam(pp);

    % load
    disp(['getting data from participant ', param.subjName]);
    load([param.path, '\saved_data\saccadeEffects', oneOrTwoD_options{oneOrTwoD} '__', param.subjName], 'saccade','saccadesize');
    
    % smooth?
    if nsmooth > 0
        for i = 1:size(saccade.toward,1)
            saccade.toward(i,:)  = smoothdata(squeeze(saccade.toward(i,:)), 'gaussian', nsmooth);
            saccade.away(i,:)    = smoothdata(squeeze(saccade.away(i,:)), 'gaussian', nsmooth);
            saccade.effect(i,:)  = smoothdata(squeeze(saccade.effect(i,:)), 'gaussian', nsmooth);
        end

        %also smooth saccadesize data over time.
        for i = 1:size(saccadesize.toward,1)
            for j = 1:size(saccadesize.toward,2)
                saccadesize.toward(i,j,:) = smoothdata(squeeze(saccadesize.toward(i,j,:)), 'gaussian', nsmooth);
                saccadesize.away(i,j,:)   = smoothdata(squeeze(saccadesize.away(i,j,:)), 'gaussian', nsmooth);
                saccadesize.effect(i,j,:) = smoothdata(squeeze(saccadesize.effect(i,j,:)), 'gaussian', nsmooth);
            end
        end
    end

    % put into matrix, with pp as first dimension
    d1(s,:,:) = saccade.toward;
    d2(s,:,:) = saccade.away;
    d3(s,:,:) = saccade.effect;

    d4(s,:,:,:) = saccadesize.toward;
    d5(s,:,:,:) = saccadesize.away;
    d6(s,:,:,:) = saccadesize.effect;
end

%% make GA for the saccadesize fieldtrip structure data, to later plot as "time-frequency map" with fieldtrip. For timecourse data, we directly plot from d structures above. 
saccadesize.toward = squeeze(mean(d4));
saccadesize.away   = squeeze(mean(d5));
saccadesize.effect = squeeze(mean(d6));

%% all subs
if plotSinglePps
    % toward & away - all colour
    figure;
    for sp = 1:s
        subplot(subplot_size,subplot_size,sp); hold on;
        plot(saccade.time, squeeze(d1(sp,1,:)));
        plot(saccade.time, squeeze(d2(sp,1,:)));
        plot(xlim, [0,0], '--k');
        xlim(xlimtoplot);
        ylim([-0.5 0.5]);
        title(pp2do(sp));
    end
    legend({'all colour'});

    % toward & away - all duration
    figure;
    for sp = 1:s
        subplot(subplot_size,subplot_size,sp); hold on;
        plot(saccade.time, squeeze(d1(sp,6,:)));
        plot(saccade.time, squeeze(d2(sp,6,:)));
        plot(xlim, [0,0], '--k');
        xlim(xlimtoplot);
        ylim([-0.5 0.5]);
        title(pp2do(sp));
    end
    legend({'all duration'});

    % toward vs away - all colour
    figure;
    for sp = 1:s
        subplot(subplot_size,subplot_size,sp); hold on;
        plot(saccade.time, squeeze(d3(sp,1,:)));
        plot(xlim, [0,0], '--k');
        xlim(xlimtoplot);
        ylim([-0.5 0.5]);
        title(pp2do(sp));
    end
    legend({'all colour'});

    % toward vs away - all duration
    figure;
    for sp = 1:s
        subplot(subplot_size,subplot_size,sp); hold on;
        plot(saccade.time, squeeze(d3(sp,6,:)));
        plot(xlim, [0,0], '--k');
        xlim(xlimtoplot);
        ylim([-0.5 0.5]);
        title(pp2do(sp));
    end
    legend({'all duration'});

    % toward vs away - all colour AND all duration
    figure;
    for sp = 1:s
        subplot(subplot_size,subplot_size,sp); hold on;
        plot(saccade.time, squeeze(d3(sp,1,:)));
        plot(saccade.time, squeeze(d3(sp,6,:)));
        plot(xlim, [0,0], '--k');
        xlim(xlimtoplot);
        ylim([-0.5 0.5]);
        title(pp2do(sp));
    end
    legend({'all colour', 'all duration'});

    % towardness for all conditions in colour
    figure;
    for sp = 1:s
        subplot(subplot_size,subplot_size,sp);
        cfg = [];
        cfg.parameter = 'effect';
        cfg.figure = 'gcf';
        cfg.zlim = [-.1 .1];
        cfg.xlim = xlimtoplot;
        hold on;
        saccadesize.effect = squeeze(d6(sp,:,:,:)); % put in data from this pp
        cfg.channel = 1; % all conditions combined.
        ft_singleplotTFR(cfg, saccadesize);
        title(pp2do(sp));
        colormap('jet');
    end

    % towardness for all conditions in duration
    figure;
    for sp = 1:s
        subplot(subplot_size,subplot_size,sp);
        cfg = [];
        cfg.parameter = 'effect';
        cfg.figure = 'gcf';
        cfg.zlim = [-.1 .1];
        cfg.xlim = xlimtoplot;
        hold on;
        saccadesize.effect = squeeze(d6(sp,:,:,:)); % put in data from this pp
        cfg.channel = 6; % all conditions combined.
        ft_singleplotTFR(cfg, saccadesize);
        title(pp2do(sp));
        colormap('jet');
    end
end

%% Plot grand average data patterns of interest, with error bars
if plotGAs
    % plot toward, away and effect - all colour
    figure; 
    hold on
    p1 = frevede_errorbarplot(saccade.time, squeeze(d1(:,1,:)), 'b', 'se');
    p2 = frevede_errorbarplot(saccade.time, squeeze(d2(:,1,:)), 'r', 'se');
    legend([p1, p2], {'toward', 'away'});
    ylim([0, 0.8]);
    xlim(xlimtoplot);
    ylabel('Rate (Hz)');
    xlabel('Time (ms)');
    title('Colour - all');
    hold off

    % plot toward, away and effect - all duration
    figure; 
    hold on
    p3 = frevede_errorbarplot(saccade.time, squeeze(d1(:,6,:)), 'b', 'se');
    p4 = frevede_errorbarplot(saccade.time, squeeze(d2(:,6,:)), 'r', 'se');
    legend([p3, p4], {'toward', 'away'});
    ylim([0, 0.8]);
    xlim(xlimtoplot);
    ylabel('Rate (Hz)');
    xlabel('Time (ms)');
    title('Duration - all');
    hold off

    % plot the effect of both task types
    figure;
    hold on
    p5 = frevede_errorbarplot(saccade.time, squeeze(d3(:,1,:)), 'b', 'se');
    p6 = frevede_errorbarplot(saccade.time, squeeze(d3(:,6,:)), 'k', 'se');
    xlim(xlimtoplot);
    plot(xlim, [0,0], '--', 'Color', [0.6, 0.6, 0.6]);
    plot([0,0], ylim, '--', 'Color', [0.6, 0.6, 0.6]);
    legend([p5, p6], {'colour', 'duration'});
    ylabel('Rate (Hz)');
    xlabel('Time (ms)');
    title('Colour effect vs. duration effect')
    hold off

    %% saccade effect split by start task
    figure;
    subplot(1,2,1)
    hold on
    p5 = frevede_errorbarplot(saccade.time, squeeze(d3(pp_start_colour(pp2do),1,:)), 'b', 'se');
    p6 = frevede_errorbarplot(saccade.time, squeeze(d3(pp_start_colour(pp2do),6,:)), 'k', 'se');
    xlim(xlimtoplot);
    plot(xlim, [0,0], '--', 'Color', [0.6, 0.6, 0.6]);
    plot([0,0], ylim, '--', 'Color', [0.6, 0.6, 0.6]);
    legend([p5, p6], {'colour', 'duration'});
    ylabel('Rate (Hz)');
    xlabel('Time (ms)');
    title('Colour effect vs. duration effect (START colour)')
    hold off

    subplot(1,2,2)
    hold on
    p5 = frevede_errorbarplot(saccade.time, squeeze(d3(pp_start_duration(pp2do),1,:)), 'b', 'se');
    p6 = frevede_errorbarplot(saccade.time, squeeze(d3(pp_start_duration(pp2do),6,:)), 'k', 'se');
    xlim(xlimtoplot);
    plot(xlim, [0,0], '--', 'Color', [0.6, 0.6, 0.6]);
    plot([0,0], ylim, '--', 'Color', [0.6, 0.6, 0.6]);
    legend([p5, p6], {'colour', 'duration'});
    ylabel('Rate (Hz)');
    xlabel('Time (ms)');
    title('Colour effect vs. duration effect (START duration)')
    hold off
    %% just effect as function of saccade size
    cfg = [];
    cfg.parameter = 'effect';
    cfg.figure = 'gcf';
    cfg.zlim = [-0.07, 0.07];
    cfg.xlim = xlimtoplot;  
    cfg.colormap = 'jet';
    c = 0;

    % per condition
    figure;
    for chan = [1,6]
        c = c + 1;
        hold on
        cfg.channel = chan;
        subplot(2,1,c);
        saccadesize.effect = squeeze(mean(d6(:,:,:,:))); % put in data from all pp
        ft_singleplotTFR(cfg, saccadesize);
        ylabel('Saccade size (dva)');
        xlabel('Time (ms)');
        xlim(xlimtoplot);
    end
  
end

%% Plot main figure for paper
if plotFigures
    
    %% first determine significance 
    statcfg.xax = saccade.time;
    statcfg.npermutations = 10000;
    statcfg.clusterStatEvalaluationAlpha = 0.05;
    statcfg.nsub = size(pp2do,2);
    statcfg.statMethod = 'montecarlo';
    
    timeframe = [701:1701]; %this is 0 to 1500 ms post-cue
    
    colour_data = d3(:,1,timeframe);
    duration_data = d3(:,6,timeframe);
    null_data = zeros(size(colour_data));
    
    stat_colour = frevede_ftclusterstat1D(statcfg, colour_data, null_data)
    stat_duration = frevede_ftclusterstat1D(statcfg, duration_data, null_data)
    stat_compare = frevede_ftclusterstat1D(statcfg, colour_data, duration_data)
    
    colour_mask = double(stat_colour.mask);
    colour_mask(colour_mask==0) = nan;

    duration_mask = double(stat_duration.mask);
    duration_mask (duration_mask ==0) = nan;

    compare_mask = double(stat_compare.mask);
    compare_mask(compare_mask==0) = nan;
    
    %% make figure
    % settings for plots
    line = 2;
    fontsize = 17;
    x_ticks = [0, 500, 1000];
    y_ticks_rates = [0, 0.25, 0.5, 0.75];
    ylim_rates = [0, 0.75];
    y_ticks_effects = [0, 0.1, 0.2, 0.3];
    ylim_effects = [-0.1, 0.3];
    sig_offset_colour = -0.05;
    sig_offset_compare = -0.075;
    
    cfg = [];
    cfg.parameter = 'effect';
    cfg.figure = 'gcf';
    cfg.zlim = [-0.075, 0.075];
    cfg.xlim = xlimtoplot;  
    cfg.colormap = brewermap(1000, 'RdBu');

    % make actual figure ✨
    figure;

    tL = subplot(2,3,1);
    hold on
    p1 = frevede_errorbarplot(saccade.time, squeeze(d1(:,1,:)), get_colour("blue", ""), 'se');
    p2 = frevede_errorbarplot(saccade.time, squeeze(d2(:,1,:)), get_colour("red", ""), 'se');
    p1.LineWidth = line;
    p2.LineWidth = line;
    legend([p1, p2], {'toward', 'away'}, 'EdgeColor','none', 'AutoUpdate','off', 'FontSize', 17);
    xline(0, 'LineWidth', line, 'Color',[107, 107, 107]/255, 'LineStyle','--');
    ylim(ylim_rates);
    xlim(xlimtoplot);
    xticks(x_ticks);
    yticks(y_ticks_rates);
    ylabel('Saccade rate (Hz)');
    hold off

    tM = subplot(2,3,2);
    hold on
    p1 = frevede_errorbarplot(saccade.time, squeeze(d1(:,6,:)), get_colour("blue", ""), 'se');
    p2 = frevede_errorbarplot(saccade.time, squeeze(d2(:,6,:)), get_colour("red", ""), 'se');
    p1.LineWidth = line;
    p2.LineWidth = line;
    legend([p1, p2], {'toward', 'away'}, 'EdgeColor','none', 'AutoUpdate','off', 'FontSize', fontsize);
    xline(0, 'LineWidth', line, 'Color',[107, 107, 107]/255, 'LineStyle','--');
    ylim(ylim_rates);
    xlim(xlimtoplot);
    xticks(x_ticks);
    yticks(y_ticks_rates);
    ylabel('Saccade rate (Hz)');
    hold off

    tR = subplot(2,3,3);
    hold on
    p1 = frevede_errorbarplot(saccade.time, squeeze(d3(:,1,:)), get_colour("pink", ""), 'se');
    p2 = frevede_errorbarplot(saccade.time, squeeze(d3(:,6,:)), get_colour("green", ""), 'se');
    p1.LineWidth = line;
    p2.LineWidth = line;
    legend([p1, p2], {'colour', 'duration'}, 'EdgeColor','none', 'AutoUpdate','off', 'FontSize', fontsize);
    plot(saccade.time(timeframe), colour_mask*sig_offset_colour, 'Color', get_colour("pink", ""), 'LineWidth', 3);
    plot(saccade.time(timeframe), compare_mask*sig_offset_compare, 'Color', 'k', 'LineWidth', 3);
    xline(0, 'LineWidth', line, 'Color',[107, 107, 107]/255, 'LineStyle','--');
    yline(0, 'LineWidth', line, 'Color',[107, 107, 107]/255, 'LineStyle','--');
    ylim(ylim_effects);
    xlim(xlimtoplot);
    xticks(x_ticks);
    yticks(y_ticks_effects);
    ylabel('Saccade bias (Hz)');
    hold off

    bL = subplot(2,3,4);
    hold on
    cfg.channel = 1;
    ft_singleplotTFR(cfg, saccadesize);
    % yline(6-4/2, 'LineWidth',2, 'Color',[107, 107, 107]/255, 'LineStyle','--');
    xline(0, 'LineWidth',2, 'Color',[107, 107, 107]/255, 'LineStyle','--');
    xticks(x_ticks);
    ylim([0.25, 6]);
    ylabel('Saccade size (degrees)');
    title([]);
    colorbar('off');
    xline(-100, 'LineWidth', 1, 'Color', [0,0,0], 'Alpha', 1);
    xline(1000, 'LineWidth', 0.7, 'Color', [0,0,0], 'Alpha', 1);
    yline(0.25, 'LineWidth', 1, 'Color', [0,0,0], 'Alpha', 1);
    yline(6.0, 'LineWidth', 1, 'Color', [0,0,0], 'Alpha', 1);
    plot([0,0], [0.25, 0.32], 'LineWidth', 1, 'Color', [0,0,0]);
    plot([500,500], [0.25, 0.32], 'LineWidth', 1, 'Color', [0,0,0]);
    plot([0,0], [5.93, 6.0], 'LineWidth', 1, 'Color', [0,0,0]);
    plot([500,500], [5.93, 6.0], 'LineWidth', 1, 'Color', [0,0,0]);


    bM = subplot(2,3,5);
    hold on
    cfg.channel = 6;
    ft_singleplotTFR(cfg, saccadesize);
    % yline(6-4/2, 'LineWidth',2, 'Color',[107, 107, 107]/255, 'LineStyle','--');
    xline(0, 'LineWidth',2, 'Color',[107, 107, 107]/255, 'LineStyle','--');
    xticks(x_ticks);
    ylim([0.25, 6]);
    ylabel('Saccade size (degrees)');
    title([]);
    c = colorbar();
    c.Position = [0.667 0.21 0.012 0.11];
    c.Ticks = [-0.05, 0, 0.05];
    xline(-100, 'LineWidth', 1, 'Color', [0,0,0], 'Alpha', 1);
    xline(1000, 'LineWidth', 0.7, 'Color', [0,0,0], 'Alpha', 1);
    yline(0.25, 'LineWidth', 1, 'Color', [0,0,0], 'Alpha', 1);
    yline(6.0, 'LineWidth', 1, 'Color', [0,0,0], 'Alpha', 1);
    plot([0,0], [0.25, 0.32], 'LineWidth', 1, 'Color', [0,0,0]);
    plot([500,500], [0.25, 0.32], 'LineWidth', 1, 'Color', [0,0,0]);
    plot([0,0], [5.93, 6.0], 'LineWidth', 1, 'Color', [0,0,0]);
    plot([500,500], [5.93, 6.0], 'LineWidth', 1, 'Color', [0,0,0]);

    % general formatting
    set(gcf(), 'Position', [500 200 1500 1000]);
    axes = {tL, tM, tR, bL, bM};
    for i = 1:size(axes,2)
        xlabel(axes{i}, 'Time after cue onset (ms)', 'FontName', 'Aptos');
        set(axes{i}, 'Box', 'on');
        axis(axes{i}, "square");
        set(axes{i}, 'FontSize', fontsize);
        set(axes{i}, 'FontName', 'Aptos');
        set(axes{i}, 'LineWidth', 1);
        
    end
    % move bottom figures up
    set(bL, 'Position', [0.1311, 0.1700, 0.2073, 0.3412]);
    set(bM, 'Position', [0.4119, 0.1700, 0.2073, 0.3412]);
    
    set(gcf, 'Renderer', 'Painters');

    print("..\..\..\..\Manuscripts\colour-vs.-duration\Figures\Saccade", "-dsvg", "-vector")
    print("..\..\..\..\Manuscripts\colour-vs.-duration\Figures\Saccade", "-dpng")
end