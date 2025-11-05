function param = getSubjParam(pp)

%% participant-specific notes

%% set path and pp-specific file locations
unique_numbers = [12, 60, 94, 72]; %needs to be in the right order

param.path = '\\scistor.vu.nl\shares\FGB-ETP-CogPsy-ProactiveBrainLab\core_lab_members\Laurie\duration_color\';

if pp < 10
    param.subjName = sprintf('pp0%d', pp);
else
    param.subjName = sprintf('pp%d', pp);
end

param.colour_beh = [param.path, sprintf('data_session_%d_%s.csv', pp, "colour")];
param.duration_beh = [param.path, sprintf('data_session_%d_%s.csv', pp, "duration")];

param.col_eye = [param.path, sprintf('%d_%d_%s.asc', pp, unique_numbers(pp), "c")];
param.dur_eye = [param.path, sprintf('%d_%d_%s.asc', pp, unique_numbers(pp), "d")];
