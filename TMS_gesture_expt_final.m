clear all

% COLLECT SUBJECT INFO
subject_ID = input('Enter subject ID (do not include letters): ');
cur_path = pwd;

if isdir([cur_path,'/data'])
else mkdir('data')
end

subject_ID = sprintf('%d',subject_ID);

if isdir([cur_path,'/data/',subject_ID])
    sub_dir = [cur_path,'/data/',subject_ID];
else mkdir([cur_path,'/data/',subject_ID]);
    sub_dir = [cur_path,'/data/',subject_ID];
end

IRB_number = input('IRB number: ');
ucsdstudent = input('UCSD student (y=yes, n=no)? ', 's');
subjage = input('Subject age (enter 1-100)? ');
subjsex = input('Subject sex (m=male, f=female)? ', 's');
handedness = input('Is the subject right-handed or left-handed (r=right, l=left)? ', 's');

tms = 0;




% EXPERIMENT START -- key/variable setting
limited_hold = 6;
left_key = {'z'};
right_key = {'/?'};
num_keys = {'1!','2@','3#','4$','5%','6^','7&','8*','9('};
allowable_keys = {left_key{1},right_key{1}, num_keys{1:9}};
key_response = 4;
keypad_index = 0;

fixation_duration = 2;

KbName('UnifyKeyNames');
space=KBName('SPACE');
esc=KbName('ESCAPE');
resp1 = KBName('1!');
resp2 = KBName('2@');

abortkeys = esc;

HideCursor;

main_keyboard_index = input_device_by_prompt('Please press any key on the main keyboard\n', 'keyboard');

fixation = '+';

% gesture_only_dir = [pwd,'/gesture_only/'];
% sentence_only_dir = [pwd,'/sentence_only/'];
% gestsent_both_dir = [pwd,'/gestsent_both/'];

importfile('video_filenames.xls','gesture');
gesture_only_vids = textdata;
importfile('video_filenames.xls','sentence');
sentence_only_vids = textdata;
importfile('video_filenames.xls','both');
gestsent_both_vids = textdata;

importfile('video_filenames.xls','question');
scale_question = textdata;
importfile('video_filenames.xls','option');
scale_option = textdata;
% importfile('video_filenames.xls','correct');
% scale_correct = textdata;


% Child Protection
AssertOpenGL;

% Open onscreen window:
screen = max(Screen('Screens'));
[win, scr_rect] = Screen('OpenWindow',screen);
[winWidth, winHeight] = Screen('WindowSize',win);

% black = BlackIndex(win); % should be equal to 0
% white = WhiteIndex(win); % should be equal to 255
black = [0 0 0];
white = [255 255 255];
gray = GrayIndex(win);
background = black;

xcenter = winWidth/2;
ycenter = winHeight/2;
center_rect = [xcenter - 10, ycenter - 10, xcenter + 10, ycenter + 10];

% Clear screen to background color:
Screen('FillRect',win,black);

% Initialize display and sync to timestamp:
vbl = Screen('Flip',win);
theFont = 'Garamond';
Screen('TextSize',win,36);
Screen('TextFont', win,theFont);
Screen('TextColor',win,white);
fixation_size = 50;
WaitSecs(.5);





%% TASK INSTRUCTIONS START
Screen('TextSize',win,50);
DrawFormattedText(win,'Language and Gesture Experiment\n\n When you are ready to continue, press any key.\n\n','center','center',white);
Screen('Flip',win);

WaitSecs(.2); [secs, keyCode] = KBWait(main_keyboard_index);
if keyCode(KbName('ESCAPE'))
    clear Screen
    fprintf('Experiment stopped');
    return
end

Screen('TextSize',win,32);
DrawFormattedText(win,'If you see the word "Now!" after a video trial,\n\n hit the spacebar as fast as you can. \n\n\n\nOtherwise, answer the comprehension question with "1" or "2" on the keyboard. \n\n\n\nHit any key to start.\n\n','center','center',white);
Screen('Flip',win);

WaitSecs(.2); [secs, keyCode] = KBWait(main_keyboard_index);
if keyCode(KbName('ESCAPE'))
    clear Screen
    fprintf('Experiment stopped');
    return
end

start_instructions = GetSecs;

% Assign video types and attention questions
trial_dataset = dataset();
trial_dataset.trial(1:240,1) = 1:240;
trial_dataset.scale_question(41:1:240,1) = {'Now!'};
trial_dataset.scale_option(41:1:240,1) = {''};
% trial_dataset.scale_correct(41:1:240,1) = space;

trial_dataset.stim(1:1:40,1) = gestsent_both_vids;
trial_dataset.scale_question(1:1:40,1) = scale_question;
trial_dataset.scale_option(1:1:40,1) = scale_option;
% trial_dataset.scale_correct(1:1:40,1) = scale_correct;

trial_dataset.stim(41:1:80,1) = gestsent_both_vids;
% trial_dataset.scale_correct(41:1:80,1) = scale_correct;

trial_dataset.stim(81:1:120,1) = gestsent_both_vids;
% trial_dataset.scale_correct(81:1:120,1) = scale_correct;

trial_dataset.stim(121:1:160,1) = gestsent_both_vids;
% trial_dataset.scale_correct(121:1:160,1) = scale_correct;

trial_dataset.stim(161:1:200,1) = gestsent_both_vids;
% trial_dataset.scale_correct(161:1:200,1) = scale_correct;

trial_dataset.stim(201:1:240,1) = gestsent_both_vids;
% trial_dataset.scale_correct(201:1:240,1) = scale_correct;

trial_dataset.type(1:1:240,1) = {'gesture + sentence'};

% Set TMS pulse times
pulse1 = -500;
pulse2 = 200;
pulse3 = 300;
pulse4 = 400;
pulse5 = 500;
pulse6 = 600;

for i = 1:40
    trial_dataset.TMSpulseonset(i,1) = pulse1;
end
for i = 41:80
    trial_dataset.TMSpulseonset(i,1) = pulse2;
end
for i = 81:120
    trial_dataset.TMSpulseonset(i,1) = pulse3;
end
for i = 121:160
    trial_dataset.TMSpulseonset(i,1) = pulse4;
end
for i = 161:200
    trial_dataset.TMSpulseonset(i,1) = pulse5;
end
for i = 201:240
    trial_dataset.TMSpulseonset(i,1) = pulse6;
end

% Randomize trials
trial_order = randperm(240);
trial_dataset.trial(:,1) = (trial_order);
trial_dataset = sortrows(trial_dataset,'trial');

% Assign blocks = 8 blocks of 30 = 240 total
tmp = 1;
for i = 1:30:length(trial_dataset)
    trial_dataset.block(i:i+29,1) = tmp;
    tmp = tmp+1;
end

% Assign RT and time onset columns
trial_dataset.stimonset(1:length(trial_dataset),1) = NaN;
trial_dataset.scaleRT(1:length(trial_dataset),1) = NaN;

% Initialize the TMS daq
if tms == 1
    send_to_tms_daq('initialize');
end

if tms == 1 && trial_dataset.TMSpulseonset(trial)
    while GetSecs == ISI_offset_time - 0.3
    end
    % EMG sweep trigger
    send_to_tms_daq('sweep');
    trial_dataset.TMSpulseonset(trial) = GetSecs;
    % Send trigger signal to EMG
    send_to_tms_daq('marker',num2str(trial));
end





%% PRESENT STIMULI
Screen('Preference','VisualDebugLevel',1);

for trial = 1:4;
    Screen('TextSize',win,80);
    DrawFormattedText(win,fixation,'center','center',white);
    Screen('Flip',win);
    WaitSecs(fixation_duration);
    
    a = trial_dataset.stim(trial);
    b = cell2str(a);
    c = strtrim(b);
    moviename = strrep(c,'\n','');
    
    SimpleMovieDemo_v2(moviename);
    trial_dataset.stimonset(trial,1) = GetSecs;
    
    Screen('TextSize',win,80);
    DrawFormattedText(win,fixation,'center','center',white);
    Screen('Flip',win);
    WaitSecs(fixation_duration);
    
    if strcmp('Now!', trial_dataset.scale_question(trial,1))==1
        Screen('TextSize',win,80);
        DrawFormattedText(win,cell2str(trial_dataset.scale_question(trial,1)),'center','center',white);
        Screen('Flip',win);
        start_rate_time = GetSecs;
        
        % Check the state of the keyboard.
        [secs, keyCode, deltaSecs] = KbWait;
        KbWait;
        if keyCode(space)
            trial_dataset.scale_response(trial,1) = find(keyCode);
            trial_dataset.scaleRT(trial,1) = secs - start_rate_time;
            flushevents('keyDown');
            Screen('Flip', win);
        end
        
    else
        Screen('TextSize',win,32);
        DrawFormattedText(win, cell2str(trial_dataset.scale_question(trial,1)), xcenter-625, ycenter-300, white);
        DrawFormattedText(win, cell2str(trial_dataset.scale_option(trial,1)), xcenter-350, ycenter-80, white);
        Screen('Flip',win);
        start_rate_time = GetSecs;
        
        % Check the state of the keyboard.
        [secs, keyCode, deltaSecs] = KbWait;
        KbWait;
        if keyCode(resp1) || keyCode(resp2)
            trial_dataset.scale_response(trial,1) = find(keyCode);
            trial_dataset.scaleRT(trial,1) = secs - start_rate_time;
            flushevents('keyDown');
            Screen('Flip', win);
        end
    end
    
    % End the block after 30 trials
    if rem(trial,2)==0
        Screen('TextSize',win,50);
        DrawFormattedText(win, 'You have reached the end of a trial block.\n\nTo continue, hit any key.','center','center',white);
        Screen('Flip',win);
        WaitSecs(.2); [secs, keyCode] = KBWait(main_keyboard_index);
    end
    
    % End the experiment after 240 trials
    if rem(trial,4)==0
        Screen('TextSize',win,50);
        DrawFormattedText(win,'You are now done with the experiment!\n\nThank you for participating.\n\nHit any key to exit.','center','center',white);
        Screen('Flip',win);
        WaitSecs(.2); [secs, keyCode] = KBWait(main_keyboard_index);
        Screen('CloseAll');
    end
end


Screen('Preference','VisualDebugLevel',4)
outfile=sprintf('sub%s_TMSEvan_%s.mat', subject_ID, date);
save(['data/', subject_ID, '/', outfile],'trial_dataset', 'subject_ID', 'date');