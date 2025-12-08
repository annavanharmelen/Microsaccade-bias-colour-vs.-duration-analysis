function param = getSubjParam(pp)

%% participant-specific notes

%% set path and pp-specific file locations
unique_numbers = [12, 60, 94, 72, 57, 31, 21, 91, 41, 19, 67, 49, 24, 79, 42, 59, 93, 45, 95, 18, 77, 32, 58, 90, 35]; %needs to be in the right order

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
