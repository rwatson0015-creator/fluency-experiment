Screen('Preference', 'SkipSyncTests', 1);
sca;
close all;
clear;
PsychDefaultSetup(2);

t_fluency  = 30;
t_fixation = 8;
t_rest     = 60;
runs       = 3;
numBlocks  = 3;

runSequences = {
    {'spsp', 'pssp', 'psps'}, ...
    {'psps', 'spps', 'spsp'}, ...
    {'spps', 'pssp', 'spps'}  ...
};

categories = {'Fruits', 'Vegetables', 'Birds', 'Insects', 'Cities', ...
'Countries', 'Jobs', 'Musical Instruments', 'Colors', 'Clothes', ...
'Household Items', 'Electronic Devices', 'Drinks', 'Desserts', ...
'Body Parts', 'Plants', 'Games', 'Toys', 'Vehicles', 'School Supplies'};

letters = {'A','B','C','D','E','F','G', ...
'H','I','K','L','M','N','O','P','R','S','T','U','W'};

allC = categories(randperm(length(categories)));
allL = letters(randperm(length(letters)));
cIdx = 1;
lIdx = 1;

% --- Audio setup ---
InitializePsychSound(1);
fs        = 44100;
nChannels = 1;
paRec = PsychPortAudio('Open', [], 2, 0, fs, nChannels);
PsychPortAudio('GetAudioData', paRec, 40);

outputDir = fullfile(fileparts(mfilename('fullpath')), 'audio_recordings');
if ~exist(outputDir, 'dir')
    mkdir(outputDir);
end

% --- Screen setup ---
screens      = Screen('Screens');
screenNumber = max(screens);
grey         = GrayIndex(screenNumber);
black        = BlackIndex(screenNumber);
red          = [255, 0, 0];

[window, windowRect] = PsychImaging('OpenWindow', screenNumber, grey);
Screen('TextSize', window, 120);

% I dont know what the trigger key for this is so i just put a placeholder
triggerKey = KbName('5%');

for run = 1:runs

    DrawFormattedText(window, ['Run ' num2str(run) '\nWaiting for scanner...'], 'center', 'center', black);
    Screen('Flip', window);

    while true
        [~, ~, keyCode] = KbCheck;
        if keyCode(triggerKey)
            break;
        end
    end

    thisRunBlocks = runSequences{run};

    for b = 1:numBlocks
        currentBlockStr = thisRunBlocks{b};

        for i = 1:4

            
            DrawFormattedText(window, '+', 'center', 'center', red);
            Screen('Flip', window);
            WaitSecs(t_fixation);

           
            trialType = currentBlockStr(i);

            if trialType == 's'
                if cIdx > length(allC)
                    allC = categories(randperm(length(categories)));
                    cIdx = 1;
                end
                msg = ['List different\n' upper(allC{cIdx})];
                cIdx = cIdx + 1;
            else
                if lIdx > length(allL)
                    allL = letters(randperm(length(letters)));
                    lIdx = 1;
                end
                msg = ['List words starting with\n' allL{lIdx}];
                lIdx = lIdx + 1;
            end

            DrawFormattedText(window, msg, 'center', 'center', black);
            Screen('Flip', window);

            PsychPortAudio('GetAudioData', paRec);
            PsychPortAudio('Start', paRec, 0, 0, 1);
            WaitSecs(t_fluency);
            PsychPortAudio('Stop', paRec);
            audioData = PsychPortAudio('GetAudioData', paRec);

            filename = fullfile(outputDir, ...
                sprintf('run%d_block%d_trial%d_%s.wav', run, b, i, trialType));
            audiowrite(filename, audioData', fs);
        end
    end

    % Rest between runs (skip after last run)
    if run < runs
        DrawFormattedText(window, 'Rest\nNext run begins in 1 minute.', 'center', 'center', black);
        Screen('Flip', window);
        WaitSecs(t_rest);
    end

end

% --- Cleanup ---
PsychPortAudio('Close', paRec);
sca;