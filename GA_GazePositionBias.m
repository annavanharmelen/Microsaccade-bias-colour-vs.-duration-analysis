
%% Step2b--grand average plots of gaze-position results

%% start clean
clear; clc; close all;

%% parameters
pp2do = [2:25];

nsmooth             = 200;
baselineCorrect     = 0;
removeTrials        = 0; % use data with removed trials based on gaze deviation from baseline

plotSinglePps       = 1;
plotGAs             = 1;
xlimtoplot          = [-750 2500];

%% load and aggregate the data from all pp
s = 0;
for pp = pp2do;
    s = s+1;

    % get participant data
    param = getSubjParam(pp);

    % load
    disp(['getting data from participant ', param.subjName]);

    if baselineCorrect == 1     toadd1 = '_baselineCorrect'; else toadd1 = ''; end % depending on this option, append to name of saved file.
    if removeTrials == 1        toadd2 = '_removeTrials';    else toadd2 = ''; end % depending on this option, append to name of saved file.

    load([param.path, '\saved_data\gazePositionEffects', toadd1, toadd2, '__', param.subjName], 'gaze');

    % smooth?
    if nsmooth > 0
        for x1 = 1:size(gaze.dataL,1);
            gaze.dataL(x1,:)      = smoothdata(squeeze(gaze.dataL(x1,:)), 'gaussian', nsmooth);
            gaze.dataR(x1,:)      = smoothdata(squeeze(gaze.dataR(x1,:)), 'gaussian', nsmooth);
            gaze.towardness(x1,:) = smoothdata(squeeze(gaze.towardness(x1,:)), 'gaussian', nsmooth);
            gaze.blinkrate(x1,:)  = smoothdata(squeeze(gaze.blinkrate(x1,:)), 'gaussian', nsmooth);
        end
    end

    % put into matrix, with pp as first dimension
    d1(s,:,:) = gaze.dataR;
    d2(s,:,:) = gaze.dataL;
    d3(s,:,:) = gaze.towardness;
    d4(s,:,:) = gaze.blinkrate;
end

%% make GA

%% all subs
if plotSinglePps
    % towardness - all colour AND all duration
    figure;
    for sp = 1:s
        subplot(5,5,sp); hold on;
        plot(gaze.time, squeeze(d3(sp,1,:)));
        plot(gaze.time, squeeze(d3(sp,6,:)));
        plot(xlim, [0,0], '--k');
        xlim(xlimtoplot); ylim([-.2 .2]);
        title(pp2do(sp));
    end
    legend(gaze.label);

    % blink rate
    figure;
    for sp = 1:s
        subplot(5,5,sp); hold on;
        plot(gaze.time, squeeze(d4(sp,1,:)));
        plot(gaze.time, squeeze(d4(sp,6,:)));
        plot(xlim, [0,0], '--k');
        xlim(xlimtoplot); ylim([-20 100]);
        title(pp2do(sp));
    end
    legend(gaze.label);
end

%% plot grand average data patterns of interest, with error bars
if plotGAs
    % plot toward, away and effect - all colour
    figure;
    hold on;
    title(gaze.label(1));
    p3 = frevede_errorbarplot(gaze.time, squeeze(d1(:,1,:)), 'b', 'both');
    p4 = frevede_errorbarplot(gaze.time, squeeze(d2(:,1,:)), 'r', 'both');
    p5 = frevede_errorbarplot(gaze.time, squeeze(d3(:,1,:)), 'k', 'both');
    plot(xlim, [0,0], '--k');
    xlim(xlimtoplot);
    legend([p3, p4, p5], {'R','L', 'toward'});

    % plot toward, away and effect - all duration
    figure;
    hold on;
    title(gaze.label(6));
    p3 = frevede_errorbarplot(gaze.time, squeeze(d1(:,6,:)), 'b', 'both');
    p4 = frevede_errorbarplot(gaze.time, squeeze(d2(:,6,:)), 'r', 'both');
    p5 = frevede_errorbarplot(gaze.time, squeeze(d3(:,6,:)), 'k', 'both');
    plot(xlim, [0,0], '--k');
    xlim(xlimtoplot);
    legend([p3, p4, p5], {'R','L', 'toward'});

    % plot the effect of both task types
    figure;
    hold on;
    p10 = frevede_errorbarplot(gaze.time, squeeze(d3(:,1,:)), 'b', 'se');
    p11 = frevede_errorbarplot(gaze.time, squeeze(d3(:,6,:)), 'k', 'se');
    plot(xlim, [0,0], '--k');
    xlim(xlimtoplot);
    legend([p10, p11], {'colour', 'duration'});
   
    %% blink rate
    figure; 
    hold on;
    p12 = frevede_errorbarplot(gaze.time, squeeze(d4(:,1,:)), 'b', 'se');
    p13 = frevede_errorbarplot(gaze.time, squeeze(d4(:,6,:)), 'k', 'se');
    plot(xlim, [0,0], '--k');
    plot([0,0], [-5, 30], '--k')
    legend([p12,p13], gaze.label([1,6]));
    title('Blink rate in the different conditions')
    xlim(xlimtoplot);

end