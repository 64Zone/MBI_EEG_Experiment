function Pilot_Vogel()
    % fix block display acc -100%?
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%               Vogel Task                   %%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %%% Visual angle calculator: https://www.sr-research.com/visual-angle-calculator/

    %% Initialize Experiment
    clear all;
    Screen('Preference', 'ConserveVRAM', 4096);
    % Screen('Preference', 'SkipSyncTests', 0);
    Screen('Preference', 'SkipSyncTests', 1);
    Screen('Preference', 'TextRenderer', 0);
    Screen('Preference', 'TextRenderer', 1) %for formatted text
    Screen('Preference', 'TextAntiAliasing', 2);

    %% Timing variables
    fixationDur = .6; % time of arrow and fixation shown
    dur1 = 1.8; % time of first display of words
    dur2 = 2; % time until automatically moves to next trial if no response

    %% Label keys
    KbName('UnifyKeyNames');
    Key1 = KbName('LeftArrow'); Key2 = KbName('RightArrow'); corrkey = [Key1, Key2];
    spaceKey = KbName('space'); escKey = KbName('ESCAPE'); pauseKey = KbName ('p'); continueKey = KbName('c');
    activeKeys = [Key1 Key2 continueKey spaceKey escKey pauseKey];

    % for Linux (participant room keyboard), 91 for LeftArrow, '0', and 92 for RightArrow, '.'
    % leftShiftKey = KbName('left_shift');

    % KbDemo: for mac(80 Left; 79 Right)
    % for Linux (monitor room keyboard), 114 for LeftArrow and 115 for RightArrow
    % for Linux (participant room keyboard), 91 for LeftArrow and 92 for RightArrow

    %% Colors of screen
    gray = [127 127 127]; white = [255 255 255]; black = [0 0 0];
    red = [255 0 0]; blue = [0 0 255]; bgcolor = white; textcolor = black; redColor = [255 0 0];

    %% Initialize EEG ports
    % pportaddress = uint16(53264);                      % convert to unsigned 16-bit integer  -- this may need to be customized --
    % pportaddress = 'e010';                      % convert to unsigned 16-bit integer  -- this may need to be customized --
    %pportaddress = uint16(57352);      % 57360 [e010] 57344 [e000]... sudo cat /proc/ioports | grep par -- e000-e002 : parport0  e003-e007 : parport0
    pportaddress = uint16(57360); %tried 001,002 - got one, 003 - 4,128 stimulus markers, 004 - nothing,005 - nothing, 006 -nothing, 007-nothing, 008-nothing, 009-nothing, 010 - works,
    pinnums = 9:-1:2; % pin number (8-bit)
    mylogs = {};

    for i = 1:255
        mybin = dec2bin(i, numel(pinnums)); % convert decimal to 8-bit binary
        mylog = logical(num2str(mybin) * 1 + '0' - 96); % convert the 8-bit binary from string to logical array
        mylogs = [mylogs mylog]; % store the logical array of each of the 256
    end

    cleartime = 0.001;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%% THOUGHT ACTIVATION VARIABLES  %%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% EEG event codes
    redRelated = 1; blueRelated = 2;
    redNegative = 3; blueNegative = 4;
    redPositive = 5; bluePositive = 6;
    redNeutral = 7; blueNeutral = 8;
    stimcodes = [redRelated; redRelated; redRelated; redRelated; redRelated; redRelated; redRelated; redRelated; ...
                     blueRelated; blueRelated; blueRelated; blueRelated; blueRelated; blueRelated; blueRelated; blueRelated; ...
                     redNegative; redNegative; redNegative; redNegative; redNegative; redNegative; redNegative; redNegative; ...
                     blueNegative; blueNegative; blueNegative; blueNegative; blueNegative; blueNegative; blueNegative; blueNegative; ...
                     redPositive; redPositive; redPositive; redPositive; redPositive; redPositive; redPositive; redPositive; ...
                     bluePositive; bluePositive; bluePositive; bluePositive; bluePositive; bluePositive; bluePositive; bluePositive; ...
                     redNeutral; redNeutral; redNeutral; redNeutral; redNeutral; redNeutral; redNeutral; redNeutral; ...
                     blueNeutral; blueNeutral; blueNeutral; blueNeutral; blueNeutral; blueNeutral; blueNeutral; blueNeutral];
    pausecode = 98; respcode = 99;
    correctcode = 100; incorrectcode = 101;

    % color lists
    colorList = [red; red; red; red; red; red; red; red; red; red; blue; blue; blue; blue; blue; blue; blue; blue; blue; blue; ...
                 red; red; red; red; red; red; red; red; red; red; blue; blue; blue; blue; blue; blue; blue; blue; blue; blue; ...
                     red; red; red; red; red; red; red; red; red; red; blue; blue; blue; blue; blue; blue; blue; blue; blue; blue; ...
                     red; red; red; red; red; red; red; red; red; red; blue; blue; blue; blue; blue; blue; blue; blue; blue; blue; ...
                     red; red; red; red; red; red; red; red; red; red; blue; blue; blue; blue; blue; blue; blue; blue; blue; blue; ];
    wordColor = {'red', 'red', 'red', 'red', 'red', 'red', 'red', 'red', 'blue', 'blue', 'blue', 'blue', 'blue', 'blue', 'blue', 'blue', ...
                     'red', 'red', 'red', 'red', 'red', 'red', 'red', 'red', 'blue', 'blue', 'blue', 'blue', 'blue', 'blue', 'blue', 'blue', ...
                     'red', 'red', 'red', 'red', 'red', 'red', 'red', 'red', 'blue', 'blue', 'blue', 'blue', 'blue', 'blue', 'blue', 'blue', ...
                     'red', 'red', 'red', 'red', 'red', 'red', 'red', 'red', 'blue', 'blue', 'blue', 'blue', 'blue', 'blue', 'blue', 'blue'};
    colorValue = [5, 5, 5, 5, 5, 5, 5, 5, 6, 6, 6, 6, 6, 6, 6, 6, ...
                      5, 5, 5, 5, 5, 5, 5, 5, 6, 6, 6, 6, 6, 6, 6, 6, ...
                      5, 5, 5, 5, 5, 5, 5, 5, 6, 6, 6, 6, 6, 6, 6, 6, ...
                      5, 5, 5, 5, 5, 5, 5, 5, 6, 6, 6, 6, 6, 6, 6, 6];

    %% Condensing color lists
    trialsPerBehavior = 100; % 100 trials per behavior in Thought Activation task
    trialsPerBehavior = 4; %testing
    n = 10; % used for making color lists, 10 elements 10 times in list, 100 length array.

    %colors vars
    %     colors_red = repelem(red, n); colors_red = reshape(colors_red, n, 3);
    %     colors_blue = repelem(blue, n); colors_blue = reshape(colors_blue, n, 3);
    %     colors_red_blue = [colors_red; colors_blue; colors_red; colors_blue; colors_red; colors_blue; colors_red; colors_blue; colors_red; colors_blue; ];

    %color values
    color_value_5 = repelem(5, n); color_value_6 = repelem(6, n);
    color_values_5_6 = [color_value_5 color_value_6 color_value_5 color_value_6 color_value_5 color_value_6 color_value_5 color_value_6 color_value_5 color_value_6];

    %full lists
    color_words_red = repelem({'red'}, n); color_words_blue = repelem({'blue'}, n);
    color_words_red_blue = [color_words_red color_words_blue color_words_red color_words_blue color_words_red color_words_blue color_words_red color_words_blue color_words_red color_words_blue];

    %%
    %%% BEHAVIORS %%%
    %%% Early Rise
    early_rise_f = {'sleep' 'bed' 'alarm' 'breakfast' 'productive'}; early_rise_c = {'finish' 'heavy' 'wedding' 'camp' 'important'};

    % 100 word array of early rise
    early_rise_f_arr = repelem(early_rise_f, 10); early_rise_c_arr = repelem(early_rise_c, 10);

    %%% Fitness Group
    fitness_group_f = {'social' 'group' 'gym' 'workout' 'weight'}; fitness_group_c = {'gas' 'modern' 'degree' 'bear' 'football'};

    % 100 word array of early rise
    fitness_group_f_arr = repelem(fitness_group_f, 10); fitness_group_c_arr = repelem(fitness_group_c, 10);

    %%% Cook Salmon
    cook_salmon_f = {'flavor' 'taste' 'cook' 'expensive' 'fish'}; cook_salmon_c = {'fluff' 'aquarium' 'hotel' 'lasting' 'fight'};

    % 100 word array of early rise
    cook_salmon_f_arr = repelem(cook_salmon_f, 10); cook_salmon_c_arr = repelem(cook_salmon_c, 10);

    %%% Fitness Tracker
    fitness_tracker_f = {'watch' 'walk' 'run' 'awareness' 'calories'}; fitness_tracker_c = {'doctor' 'hear' 'jump' 'discuss' 'youth'};

    % 100 word array of early rise
    fitness_tracker_f_arr = repelem(fitness_tracker_f, 10); fitness_tracker_c_arr = repelem(fitness_tracker_c, 10);

    %%% Wash Hands
    wash_hands_f = {'clean' 'germ' 'soap' 'water' 'hand'}; wash_hands_c = {'fair' 'accident' 'lake' 'nature' 'whole'};

    % 100 word array of early rise
    wash_hands_f_arr = repelem(wash_hands_f, 10); wash_hands_c_arr = repelem(wash_hands_c, 10);

    %%% Wash Hands
    stretch_f = {'stretch' 'yoga' 'relax' 'relief' 'flexibility'}; stretch_c = {'film' 'gazelle' 'abundance' 'blueprint' 'camera'};

    % 100 word array of early rise
    stretch_f_arr = repelem(stretch_f, 10); stretch_c_arr = repelem(stretch_c, 10);

    % all behaviors
    early_rise = [early_rise_f_arr early_rise_c_arr]; fitness_group = [fitness_group_f_arr fitness_group_c_arr]; cook_salmon = [cook_salmon_f_arr cook_salmon_c_arr];
    fitness_tracker = [fitness_tracker_f_arr fitness_tracker_c_arr]; wash_hands = [wash_hands_f_arr wash_hands_c_arr]; stretch = [stretch_f_arr stretch_c_arr];
    behaviors = [{early_rise} {fitness_group} {cook_salmon} {fitness_tracker} {wash_hands} {stretch}];

    %% Integer Array
    word_integer_arr = uint32(1):uint32(trialsPerBehavior); color_integer_arr = uint32(1):uint32(trialsPerBehavior);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%% THOUGHT ACTIVATION VARS END  %%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %% Data logging file
    %%% Create initial file
    prompt = {'Outputfile', 'Subject''s ID number:', 'version', 'protocol'};
    defaults = {'RTtask', '0101', 'L', '1-6'};
    answer = inputdlg(prompt, 'ReactionTimeTask', 2, defaults);
    output = answer{1}; subid = answer{2}; version = answer{3}; protocol = answer{4}; % assign values
    protocol = str2double(protocol); % change string to double for later use
    % check if input didn't work, do default, do try catch here instead
    % probably
    if (isnan(protocol))
        protocol = 1;
    end

    outputname = ['data/' output subid version '.xlsx']; % generate file name
    filename = ['_data/' output subid version '.xls']; %

    %%% write variables based on version
    switch version
        case 'L' % long version
            nblocks = 3; % 3 blocks per condition
            nTrialsPerBlock = 30; % 30 trials per block
            nTrialsPerCondition = nTrialsPerBlock * 3; % 90 trials per condition, 180 total
        case 'S' % short version
            nblocks = 1; % 1 block for testing
            nTrialsPerBlock = 5; % 5 trials per block, use 10 for practice and don't randomize order
            nTrialsPerCondition = nTrialsPerBlock * 3; % 6 trials per condition, 18 total
        case 'T' % short version
            nblocks = 3; % 1 block for testing
            nTrialsPerBlock = 2; % 5 trials per block
            nTrialsPerCondition = nTrialsPerBlock * 3; % 6 trials per condition, 18 total
        otherwise % default as long version
            nblocks = 3; % 3 blocks per condition
            nTrialsPerBlock = 20; % 20 trials per block
            nTrialsPerCondition = nTrialsPerBlock * 3; % 60 trials per condition, 180 total
    end

    %%% initialize the random number generator to subnumber
    subnum = str2double(subid);

    %%% check to avoid overiding an existing file
    if exist(outputname) == 2
        fileproblem = input('That file already exists! Append a .x (1), overwrite (2), or break (3/default)?');

        if isempty(fileproblem) || fileproblem == 3
            return
        elseif fileproblem == 1
            outputname = [outputname '.x'];
        end

    end

    % catch any errors
    [outfile, message] = fopen(outputname, 'w');

    if outfile < 0
        error('Failed to open myfile because: %s', message);
    end

    %%% method of logging data before trying with output cell, which seems
    %%% to work better
    % write file to data folder with heading
    %     fprintf(outfile, '%s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t \n', ...
    %     'subid', 'version', 'condition', 'blockNum', ...
    %         'nTrialsPerBlock', 'trialindex', 'isSame', ...
    %         'whichDirection', 'retentionDuration', 'rsp.RT', 'rsp.acc', ...
    %         'Instruct1Onset', 'ConditionInstructOnset', 'FixationOnset', 'StimulusOnset', ...
    %         'TestArrayOnset', 'leftWords', 'rightWords', 'subwords', ...
    %         'wordtosub', 'totalAcc', 'indexInCSV', 'keyPressed');

    %% Initialize screen parameters
    [mainwin, screenrect] = Screen('OpenWindow', 0);

    %%% initialize screen values for display
    Screen('FillRect', mainwin, bgcolor); Screen('TextSize', mainwin, 18); Screen('TextFont', mainwin, 'Courier');
    %Screen('TextFont', mainwin, '-sony-fixed-medium-r-normal--24-230-75-75-c-120-iso8859-1');

    % center = [screenrect(3) / 2 screenrect(4) / 2];

    %% Create arrow to point left or right
    head1 = [970 520]; head2 = [950 520]; width = 10; % size of arrow
    points1 = [head1 - [0, width] % top corner
                        head1 + [width, 0] % bottom corner
                        head1 + [0, width]]; % vertex
    points2 = [head2 - [width, 0] % top corner
                        head2 + [0, width] % bottom corner
                        head2 - [0, width]]; % vertex

    %% Read in trial information
    tdata = "trialdata/tdata.csv"; % read in file
    T = readtable(tdata); % read in tables
    opts = detectImportOptions(tdata); opts = setvartype(opts, 'char');
    subTable = readtable(tdata, opts); % read in data for sub words, there was an issue with the import type before
    rowindex = randi([1, 1000 - nTrialsPerCondition], 3); % get start indices randomly, total Sheet rows for tdata == 1000;

    %%% arrays for changes or not, which direction is focal, timing for
    %%% retention phase, and which word will be used to replace in last
    %%% phase of trial (4th word)
    isSame = table2array(T(:, "isSame")); whichDirection = table2array(T(:, "whichDirection")); retentionDuration = table2array(T(:, 'retentionDuration')); subword = table2array(subTable(:, "subWord")); % issues with this import before, check this

    %%% arrays for left x and y coordinates, left words, right x and y
    %%% coordinates and right words
    leftx = table2array(T(:, [{'l1cordx'}, {'l2cordx'}, {'l3cordx'}])); lefty = table2array(T(:, [{'l1cordy'}, {'l2cordy'}, {'l3cordy'}])); % left x and y coordinates
    rightx = table2array(T(:, [{'r1cordx'}, {'r2cordx'}, {'r3cordx'}])); righty = table2array(T(:, [{'r1cordy'}, {'r2cordy'}, {'r3cordy'}])); % right x and y coordinates
    leftwords = table2array(T(:, [{'l_words_word1'}, {'l_words_word2'}, {'l_words_word3'}])); rightwords = table2array(T(:, [{'r_words_word1'}, {'r_words_word2'}, {'r_words_word3'}])); % left and right words

    %%% variables to keep track of total number of correct responses and
    %%% which index it is in trial for data logging
    totalcorr = 0; % log total number of correct responses
    logindex = 1; % record which trial we're on for accurracy=totalcorr/logindex

    %% Optional: Make rects to see where stim are
    %%% use these boxes with values from ./getTrials.m
    % setLBox = SetRect(l_out,top,l_in,bottom);
    % setRBox = SetRect(r_in,top,r_out,bottom);

    %% Decide which protocol runs based on dialog box
    order_name = ['a', 'b', 'c']; % for instruct

    switch protocol
        case 1
            sprintf('Running protocol: %d\n', protocol); order = [1, 2, 3];
        case 2
            sprintf('Running protocol: %d\n', protocol); order = [2, 1, 3];
        case 3
            sprintf('Running protocol: %d\n', protocol); order = [3, 2, 1];
        case 4
            sprintf('Running protocol: %d\n', protocol); order = [2, 3, 1];
        case 5
            sprintf('Running protocol: %d\n', protocol); order = [1, 3, 2];
        case 6
            sprintf('Running protocol: %d\n', protocol); order = [3, 1, 2];
        otherwise
            sprintf('Running default protocol: %d\n', protocol); order = [1, 2, 3];
    end

    if (version == 'S')
        order = [1, 2, 3];
    end

    % initialize output matrix - trial number by number of variable columns
    header = ["subid" "version" "condition" "blockNum" "nTrialsPerBlock" "trialindex" "isSame" "whichDirection" ...
              "retentionDuration" "rsp.RT" "rsp.acc" "Instruct1Onset" "ConditionInstructOnset" "FixationOnset" "StimulusOnset" "TestArrayOnset" ...
                  "leftword1" "leftword2" "leftword3" "rightword1" "rightword2" "rightword3" "testword1" "testword2" ...
              "testword3" "wordtosub" "totalAcc" "indexInCSV" "keyPressed"]; % header for data sheet for retention task
    header_test = ["subid" "version" "nTrialsPerBehavior" "behavior" "setNum" "trialindex" ...
                       "loop_trial_index" "rt1" "keypressed1" "keyname1" "rt2" "keypressed2" "keyname2" "rt3" ...
                   "keypressed3" "keyname3" "listname" "wordcolor" "word"]; % header for data sheet for thought activation task
    output_cell = cell(nTrialsPerCondition * 3, length(header)); output_cell2 = cell(trialsPerBehavior * 6, length(header_test)); %preallocate arrays
    %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%% START EXPERIMENT %%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %     output_table = cell2table(output_cell, "VariableNames", header);
    %     writetable(output_table, filename, 'Sheet', 1)

    %%% testing TA
    %     output_table2 = cell2table(output_cell2, "VariableNames", header_test);
    %     writetable(output_table2, filename, 'Sheet', 1)

    count = 1; % keeps track of outer loop index for order array
    RestrictKeysForKbCheck(activeKeys); HideCursor(); % Restrict key press and hide cursor during experiment

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%% THOUGHT ACTIVATION %%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    disp('&&&&&&&&&&&&&&&& STARTING THOUGHT ACTIVATION TASK &&&&&&&&&&&&&&&&&&&&&&')
    timeTA = 1; timebetweenTA = 1.5; %TA task max duration of trial before moving on and time between trials
    trial_indexTA = 1;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% loop for all behaviors %%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for j = 1:6 % % % loop for all behaviors
        fprintf('RUNNING THOUGHT ACTIVATION LOOP: %d\n', j)
        %%% random values for behavior at index
        current_behavior = behaviors{j}; % get current behavior
        word_integer_arr = word_integer_arr(randperm(length(word_integer_arr))); color_integer_arr = color_integer_arr(randperm(length(color_integer_arr))); % randomize arrays each behavior to get random word and color

        %%% draw instructions for behavior
        DrawFormattedText2(sprintf('Behavior Index %d of 6\n', j), 'win', mainwin, ...
        'sx', RectWidth(screenrect) / 2, 'sy', RectHeight(screenrect) / 2, ...
            'xalign', 'center', 'yalign', 'center', 'xlayout', 'center', 'baseColor', black);

        Screen('Flip', mainwin);

        % present until keypress (spacekey)
        timeStart = GetSecs; keyIsDown = 0; correct = 0; rt = 0;

        while 1
            [keyIsDown, secs, keyCode] = KbCheck;
            FlushEvents('keyDown');

            if keyIsDown
                nKeys = sum(keyCode);

                if nKeys == 1

                    if keyCode(pauseKey) % pause if pause key
                        paused = 1;
                        DrawFormattedText2('Experiment paused.', 'win', mainwin, 'sx', RectWidth(screenrect) / 2, 'sy', RectHeight(screenrect) / 2, ...
                            'xalign', 'center', 'yalign', 'center', 'xlayout', 'center', 'baseColor', black);
                        Screen('Flip', mainwin);
                        keyIsDown = 0;

                        while 1 % check if hit key after hit pause
                            [keyIsDown, secs, keyCode] = KbCheck;

                            if keyIsDown

                                if keyCode(continueKey) % continue then break loop and continue
                                    break
                                elseif keyCode(escKey) % escape then close experiment
                                    ShowCursor; fclose(outfile); Screen('CloseAll'); return

                                end

                            end

                            break; % check if necessary
                        end

                    elseif keyCode(spaceKey) % move on if keypress if spacekey
                        rt1 = 1000 .* (GetSecs - timeStart);
                        keypressed1 = find(keyCode);
                        keyname1 = KbName(keyCode);
                        Screen('Flip', mainwin);
                        break;
                    elseif keyCode(escKey)
                         %%% write data to file
                        output_table2 = cell2table(output_cell2, "VariableNames", header_test);
                        writetable(output_table2, filename, 'Sheet', 2)
                        ShowCursor; fclose(outfile); Screen('CloseAll'); return
                    end

                    keyIsDown = 0; keyCode = 0;
                end

            end

        end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%% loop for blocks in one behavior %%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%% two loops each with 50 trials, split trialsperbehavior into 2
        %%% parts
        for k = 1:2
            % assign array for trial variables - split arrays in half and
            % use those values
            switch k
                case 1
                    set_word_integer_arr = word_integer_arr(1:(trialsPerBehavior / 2)); set_color_integer_arr = color_integer_arr(1:(trialsPerBehavior / 2));
                case 2
                    set_word_integer_arr = word_integer_arr(((trialsPerBehavior / 2) + 1):trialsPerBehavior); set_color_integer_arr = color_integer_arr(((trialsPerBehavior / 2) + 1):trialsPerBehavior);
            end

            DrawFormattedText2(sprintf('Starting block %d of 2\n', k), 'win', mainwin, 'sx', RectWidth(screenrect) / 2, 'sy', RectHeight(screenrect) / 2, ...
                'xalign', 'center', 'yalign', 'center', 'xlayout', 'center', 'baseColor', black);
            Screen('Flip', mainwin);

            % now record  response
            timeStart = GetSecs; keyIsDown = 0; correct = 0; rt = 0;

            while 1
                [keyIsDown, secs, keyCode] = KbCheck;
                FlushEvents('keyDown');

                if keyIsDown
                    nKeys = sum(keyCode);

                    if nKeys == 1

                        if keyCode(pauseKey) % pause if pause key
                            paused = 1;
                            DrawFormattedText2('Experiment paused.', 'win', mainwin, 'sx', RectWidth(screenrect) / 2, 'sy', RectHeight(screenrect) / 2, ...
                                'xalign', 'center', 'yalign', 'center', 'xlayout', 'center', 'baseColor', black);
                            Screen('Flip', mainwin);
                            keyIsDown = 0;

                            while 1 % check if hit key after hit pause
                                [keyIsDown, secs, keyCode] = KbCheck;

                                if keyIsDown

                                    if keyCode(continueKey) % continue then break loop and continue
                                        break
                                    elseif keyCode(escKey) % escape then close experiment
                                        ShowCursor; fclose(outfile); Screen('CloseAll'); return

                                    end

                                end

                                break; % check if necessary
                            end

                        elseif keyCode(spaceKey) % continue if space key
                            rt2 = 1000 .* (GetSecs - timeStart);
                            keypressed2 = find(keyCode);
                            keyname2 = KbName(keyCode);
                            Screen('Flip', mainwin);
                            break;
                        elseif keyCode(escKey)
                             %%% write data to file
                            output_table2 = cell2table(output_cell2, "VariableNames", header_test);
                            writetable(output_table2, filename, 'Sheet', 2)
                            ShowCursor; fclose(outfile); Screen('CloseAll'); return
                        end

                        keyIsDown = 0; keyCode = 0;
                    end

                end

            end

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%% loop for 50 trials in one behavior %%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            for l = 1:trialsPerBehavior / 2 % 1-50 trials
                %%% draw and present word
                word = current_behavior(set_word_integer_arr(l));

                DrawFormattedText2(word, 'win', mainwin, 'sx', RectWidth(screenrect) / 2, 'sy', RectHeight(screenrect) / 2, ...
                'xalign', 'center', 'yalign', 'center', 'xlayout', 'center', 'baseColor', colorList(set_color_integer_arr(l), :));
                Screen('Flip', mainwin);
                % now record  response
                timeStart = GetSecs; keyIsDown = 0; correct = 0; rt = 0;
                %%%TODO check logging for what happens with no response
                while GetSecs - timeStart < timeTA
                    [keyIsDown, secs, keyCode] = KbCheck;
                    FlushEvents('keyDown');

                    if keyIsDown
                        nKeys = sum(keyCode);

                        if nKeys == 1

                            if keyCode(pauseKey)
                                paused = 1;
                                DrawFormattedText2('Experiment paused.', 'win', mainwin, 'sx', RectWidth(screenrect) / 2, 'sy', RectHeight(screenrect) / 2, ...
                                    'xalign', 'center', 'yalign', 'center', 'xlayout', 'center', 'baseColor', black);
                                Screen('Flip', mainwin);
                                keyIsDown = 0;

                                while 1 % check if hit key after hit pause
                                    [keyIsDown, secs, keyCode] = KbCheck;

                                    if keyIsDown

                                        if keyCode(continueKey) % continue then break loop and continue
                                            break
                                        elseif keyCode(escKey) % escape then close experiment
                                            ShowCursor; fclose(outfile); Screen('CloseAll'); return

                                        end

                                    end

                                    break; % check if necessary
                                end

                            elseif keyCode(continueKey)
                                rt3 = 1000 .* (GetSecs - timeStart);
                                keypressed3 = find(keyCode);
                                keyname3 = KbName(keyCode);
                                Screen('Flip', mainwin);
                                break;
                            elseif keyCode(escKey)
                                 %%% write data to file
                            output_table2 = cell2table(output_cell2, "VariableNames", header_test);
                            writetable(output_table2, filename, 'Sheet', 2)
                                ShowCursor; fclose(outfile); Screen('CloseAll'); return
                            end

                            keyIsDown = 0; keyCode = 0;
                        end

                    end

                end % % % end response loop

                WaitSecs(timebetweenTA); % wait timebetweenTA seconds for next trial

                %%% start logging row data
                trial_indexTA = trial_indexTA + 1;

                %%% log word set (focal/control) and color (red/blue)
                %%% based on value of index in array
                if set_word_integer_arr(l) <= 50
                    listname = "focal";
                else listname = "control";
                end

                if set_color_integer_arr(l) <= 50
                    wordcolor = "red";
                else wordcolor = "blue";
                end
                
                %%% prepare and log data
                keyname1 = {keyname1}; keyname2 = {keyname2}; keyname3 = {keyname3}; listname = {listname}; wordcolor = {wordcolor}; % make to cell values for output in row for data logging
                row = [subid version trialsPerBehavior j k l trial_indexTA rt1 keypressed1 keyname1 rt2 keypressed2 keyname2 rt3 keypressed3 keyname3 listname wordcolor word]; % make to row
                output_cell2(trial_indexTA, :) = row; % record in row of cell variable
            end % % % end loop for 50 trials

        end % % % end loop for set (100 trials)

        %%% write data to file
        output_table2 = cell2table(output_cell2, "VariableNames", header_test);
        writetable(output_table2, filename, 'Sheet', 2)
    end % % % end loop for all behaviors

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%% WORKING MEMORY TEST %%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %%%%%% Condition Loop  %%%%%%
    while count <= 3 % condition 1-3
        fprintf('STARTING WORKING MEMORY TEST CONDITION NUMBER: %d\n', count)
        a = order(count);
        %%% determine which set of variables will be used based on which
        %%% condition, since each is read from ./trialdata/tdata.csv

        switch a % % % the 'c' before each variable means that is is the list of all trials for that condition
            case 1 % % % if a is 1 then use values from tdata.csv of 1 to 60
                %%% Condition 1 values
                cisSame = isSame(rowindex(1):rowindex(1) + nTrialsPerCondition); cwhichDirection = whichDirection(rowindex(1):rowindex(1) + nTrialsPerCondition, :); cretentionDuration = retentionDuration(rowindex(1):rowindex(1) + nTrialsPerCondition, :);
                cleftx = leftx(rowindex(1):rowindex(1) + nTrialsPerCondition, :); clefty = lefty(rowindex(1):rowindex(1) + nTrialsPerCondition, :); %left coordinates
                crightx = rightx(rowindex(1):rowindex(1) + nTrialsPerCondition, :); crighty = righty(rowindex(1):rowindex(1) + nTrialsPerCondition, :); %right coordinates
                cleftwords = leftwords(rowindex(1):rowindex(1) + nTrialsPerCondition, :); crightwords = rightwords(rowindex(1):rowindex(1) + nTrialsPerCondition, :); %left words, right words
                csubword = subword(rowindex(1):rowindex(1) + nTrialsPerCondition, :);
                indexindata = rowindex(1);
            case 2 % % % if a is 2 then use values from 61 to 120
                %%% Condition 2 values
                cisSame = isSame(rowindex(2):rowindex(2) + nTrialsPerCondition); cwhichDirection = whichDirection(rowindex(2):rowindex(2) + nTrialsPerCondition); cretentionDuration = retentionDuration(rowindex(2):rowindex(2) + nTrialsPerCondition);
                cleftx = leftx(rowindex(2):rowindex(2) + nTrialsPerCondition, :); clefty = lefty(rowindex(2):rowindex(2) + nTrialsPerCondition, :); %left coordinates
                crightx = rightx(rowindex(2):rowindex(2) + nTrialsPerCondition, :); crighty = righty(rowindex(2):rowindex(2) + nTrialsPerCondition, :); %right coordinates
                cleftwords = leftwords(rowindex(2):rowindex(2) + nTrialsPerCondition, :); crightwords = rightwords(rowindex(2):rowindex(2) + nTrialsPerCondition, :); %left words, right words
                csubword = subword(rowindex(2):rowindex(2) + nTrialsPerCondition);
                indexindata = rowindex(2);
            case 3 % % % if a is 3 then use values from 121 to 180
                %%% Condition 3 values
                cisSame = isSame(rowindex(3):rowindex(3) + nTrialsPerCondition); cwhichDirection = whichDirection(rowindex(3):rowindex(3) + nTrialsPerCondition); cretentionDuration = retentionDuration(rowindex(3):rowindex(3) + nTrialsPerCondition);
                cleftx = leftx(rowindex(3):rowindex(3) + nTrialsPerCondition, :); clefty = lefty(rowindex(3):rowindex(3) + nTrialsPerCondition, :); %left coordinates
                crightx = rightx(rowindex(3):rowindex(3) + nTrialsPerCondition, :); crighty = righty(rowindex(3):rowindex(3) + nTrialsPerCondition, :); %right coordinates
                cleftwords = leftwords(rowindex(3):rowindex(3) + nTrialsPerCondition, :); crightwords = rightwords(rowindex(3):rowindex(3) + nTrialsPerCondition, :); %left words, right words
                csubword = subword(rowindex(3):rowindex(3) + nTrialsPerCondition);
                indexindata = nTrialsPerCondition * 2 + 1;
        end

        %%% Instructions start for condition
        DrawFormattedText2(sprintf('Running condition: %c\n', order_name(a)), 'win', mainwin, 'sx', RectWidth(screenrect) / 2, 'sy', RectHeight(screenrect) / 2, ...
        'xalign', 'center', 'yalign', 'center', 'xlayout', 'center', 'baseColor', black);
        DrawFormattedText2('When you are ready to continue, press the continue key (c)', 'win', mainwin, 'sx', RectWidth(screenrect) / 2, 'sy', RectHeight(screenrect) / 2 + 50, ...
            'xalign', 'center', 'yalign', 'center', 'xlayout', 'center', 'baseColor', black);

        [~, ConditionInstructOnsetTime] = Screen('Flip', mainwin);

        %%% Check if pause key or continue
        keyIsDown = 0;

        while 1
            [keyIsDown, secs, keyCode] = KbCheck;

            if keyIsDown

                if keyCode(pauseKey) % if pause key
                    paused = 1;
                    DrawFormattedText2('Experiment paused.', 'win', mainwin, 'sx', RectWidth(screenrect) / 2, 'sy', RectHeight(screenrect) / 2, ...
                        'xalign', 'center', 'yalign', 'center', 'xlayout', 'center', 'baseColor', black);
                    Screen('Flip', mainwin);
                    keyIsDown = 0;

                    while 1 % check if hit key after hit pause
                        [keyIsDown, secs, keyCode] = KbCheck;

                        if keyIsDown

                            if keyCode(continueKey) % continue then break loop and continue
                                break
                            elseif keyCode(escKey) % escape then close experiment
                                output_table = cell2table(output_cell, "VariableNames", header);
                                writetable(output_table, filename, 'Sheet', 1)
                                ShowCursor;
                                fclose(outfile);
                                Screen('CloseAll');
                                return
                            end

                        end

                    end

                    break; % check if necessary
                elseif keyCode(continueKey) % no pause key just continue
                    break
                elseif keyCode(escKey) % no pause key just escape
                    output_table = cell2table(output_cell, "VariableNames", header);
                    writetable(output_table, filename, 'Sheet', 1)
                    ShowCursor;
                    fclose(outfile);
                    Screen('CloseAll');
                    return
                end

            end

        end

        blockindex = 1;
        blockcorr = 0; % number correct per block, for 'S' protocol

        %%%% Block Loop  %%%%
        for blockNum = 1:nblocks
            fprintf('Block Number: %d\n', blockNum);

            switch blockNum % % % the 'c' before each variable means that is is the list of all trials for that condition
                case 1
                    %%% Condition 1 values
                    bisSame = cisSame(1:nTrialsPerBlock); bretentionDuration = cretentionDuration(1:nTrialsPerBlock, :); bwhichDirection = cwhichDirection(1:nTrialsPerBlock, :);
                    bleftx = cleftx(1:nTrialsPerBlock, :); blefty = clefty(1:nTrialsPerBlock, :); %left coordinates

                    brightx = crightx(1:nTrialsPerBlock, :); brighty = crighty(1:nTrialsPerBlock, :); %right coordinates

                    bleftwords = cleftwords(1:nTrialsPerBlock, :); brightwords = crightwords(1:nTrialsPerBlock, :); %left words, right words

                    bsubword = csubword(1:nTrialsPerBlock, :);
                case 2
                    %%% Condition 2 values
                    bisSame = cisSame(nTrialsPerBlock + 1:nTrialsPerBlock * 2); bwhichDirection = cwhichDirection(nTrialsPerBlock + 1:nTrialsPerBlock * 2); bretentionDuration = cretentionDuration(nTrialsPerBlock + 1:nTrialsPerBlock * 2);
                    bleftx = cleftx(nTrialsPerBlock + 1:nTrialsPerBlock * 2, :); blefty = clefty(nTrialsPerBlock + 1:nTrialsPerBlock * 2, :); %left coordinates
                    brightx = crightx(nTrialsPerBlock + 1:nTrialsPerBlock * 2, :); brighty = crighty(nTrialsPerBlock + 1:nTrialsPerBlock * 2, :); %right coordinates

                    bleftwords = cleftwords(nTrialsPerBlock + 1:nTrialsPerBlock * 2, :); brightwords = crightwords(nTrialsPerBlock + 1:nTrialsPerBlock * 2, :); %left words, right words

                    bsubword = csubword(nTrialsPerBlock + 1:nTrialsPerBlock * 2);
                case 3
                    %%% Condition 3 values
                    bisSame = cisSame(nTrialsPerBlock * 2 + 1:nTrialsPerBlock * 3); bwhichDirection = cwhichDirection(nTrialsPerBlock * 2 + 1:nTrialsPerBlock * 3); bretentionDuration = cretentionDuration(nTrialsPerBlock * 2 + 1:nTrialsPerBlock * 3);
                    bleftx = cleftx(nTrialsPerBlock * 2 + 1:nTrialsPerBlock * 3, :); blefty = clefty(nTrialsPerBlock * 2 + 1:nTrialsPerBlock * 3, :); %left coordinates

                    brightx = crightx(nTrialsPerBlock * 2 + 1:nTrialsPerBlock * 3, :); brighty = crighty(nTrialsPerBlock * 2 + 1:nTrialsPerBlock * 3, :); %right coordinates
                    bleftwords = cleftwords(nTrialsPerBlock * 2 + 1:nTrialsPerBlock * 3, :); brightwords = crightwords(nTrialsPerBlock * 2 + 1:nTrialsPerBlock * 3, :); %left words, right words

                    bsubword = csubword(nTrialsPerBlock * 2 + 1:nTrialsPerBlock * 3);
            end

            disp('############### B IS SAME ###############')

            disp(bisSame);

            %%% block instructions
            DrawFormattedText2(sprintf('Block Number: %d. Press Space to continue.', blockNum), 'win', mainwin, ...
            'sx', RectWidth(screenrect) / 2, 'sy', RectHeight(screenrect) / 2, 'xalign', 'center', ...
                'yalign', 'center', 'xlayout', 'center', 'baseColor', black);
            [~, Instruct1OnsetTime] = Screen('Flip', mainwin);

            keyIsDown = 0;

            while 1
                [keyIsDown, secs, keyCode] = KbCheck;

                if keyIsDown

                    if keyCode(pauseKey) % if pause key
                        paused = 1;
                        DrawFormattedText2('Experiment paused.', 'win', mainwin, 'sx', RectWidth(screenrect) / 2, 'sy', RectHeight(screenrect) / 2, ...
                            'xalign', 'center', 'yalign', 'center', 'xlayout', 'center', 'baseColor', black);
                        Screen('Flip', mainwin);
                        keyIsDown = 0;

                        while 1 % check if hit key after hit pause
                            [keyIsDown, secs, keyCode] = KbCheck;

                            if keyIsDown

                                if keyCode(continueKey) % continue then break loop and continue
                                    break
                                elseif keyCode(escKey) % escape then close experiment
                                    output_table = cell2table(output_cell, "VariableNames", header);
                                    writetable(output_table, filename, 'Sheet', 1)
                                    ShowCursor;
                                    fclose(outfile);
                                    Screen('CloseAll');
                                    return
                                end

                            end

                        end

                        break; % check if necessary
                    elseif keyCode(spaceKey) % no pause key just continue
                        break
                    elseif keyCode(escKey) % no pause key just escape
                        output_table = cell2table(output_cell, "VariableNames", header);
                        writetable(output_table, filename, 'Sheet', 1)
                        ShowCursor;
                        fclose(outfile);
                        Screen('CloseAll');
                        return
                    end

                end

            end

            %%% from Zone's before, comment out for now
            %trialorder = Shuffle(1:nTrialsPerBlock);
            %correct = [];

            %%% Trial Loop  %%%
            for trialindex = 1:nTrialsPerBlock
                fprintf('Trial Number %d in Block: %d\n', trialindex, blockNum);

                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%% PHASE 1 - ARROW AND FIXATION %%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

                %%% draw arrows based on which direction is shown
                if bwhichDirection(trialindex) == 1
                    Screen('FillPoly', mainwin, [0 0 0], points2); Screen('DrawLine', mainwin, [0 0 0], 945, 520, 975, 520, 6);
                elseif bwhichDirection(trialindex) == 2
                    Screen('FillPoly', mainwin, [0 0 0], points1); Screen('DrawLine', mainwin, [0 0 0], 945, 520, 975, 520, 6);
                end

                %%% fixation
                DrawFormattedText2('+', 'win', mainwin, 'sx', RectWidth(screenrect) / 2, 'sy', RectHeight(screenrect) / 2, ...
                'xalign', 'center', 'yalign', 'center', 'xlayout', 'center', 'baseColor', redColor) %change color
                [FixationOnsetTime] = Screen('Flip', mainwin);
                time1 = FixationOnsetTime;

                %%% making pause/exit experiment available here
                keyIsDown = 0; paused = 0; keypressed = 0;

                %%% present on screen for duration of fixationDur
                while GetSecs - time1 <= fixationDur
                    [keyIsDown, secs, keyCode] = KbCheck;
                    FlushEvents('keyDown');

                    if keyIsDown
                        nKeys = sum(keyCode);

                        if nKeys == 1

                            if keyCode(pauseKey) % if pause key
                                paused = 1;
                                DrawFormattedText2('Experiment paused.', 'win', mainwin, 'sx', RectWidth(screenrect) / 2, 'sy', RectHeight(screenrect) / 2, ...
                                    'xalign', 'center', 'yalign', 'center', 'xlayout', 'center', 'baseColor', black);
                                Screen('Flip', mainwin);
                                keyIsDown = 0;

                                while 1 % check if hit key after hit pause
                                    [keyIsDown, secs, keyCode] = KbCheck;

                                    if keyIsDown

                                        if keyCode(continueKey) % continue then break loop and continue
                                            break
                                        elseif keyCode(escKey) % escape then close experiment
                                            output_table = cell2table(output_cell, "VariableNames", header);
                                            writetable(output_table, filename, 'Sheet', 1)
                                            ShowCursor;
                                            fclose(outfile);
                                            Screen('CloseAll');
                                            return
                                        end

                                    end

                                end

                                break; % check if necessary
                            elseif keyCode(escKey) % if escape key close experiment
                                output_table = cell2table(output_cell, "VariableNames", header);
                                writetable(output_table, filename, 'Sheet', 1)
                                ShowCursor; fclose(outfile); Screen('CloseAll');
                                return
                            end

                            keyIsDown = 0; keyCode = 0;
                        end

                    end

                end

                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%% PHASE 2 - FIXATION AND WORDS %%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

                %%% draw fixation
                DrawFormattedText2('+', 'win', mainwin, 'sx', RectWidth(screenrect) / 2, 'sy', RectHeight(screenrect) / 2, ...
                'xalign', 'center', 'yalign', 'center', 'xlayout', 'center', 'baseColor', redColor)

                % Optional: Draw rects to see positioning of stimuli
                %Screen('Framerect', mainwin, [0 0 0], setLBox);
                %Screen('Framerect', mainwin, [0 0 0], setRBox);

                %%% draw words, loop until condition number from protocol
                %%% order array
                for index = 1:a
                    DrawFormattedText2(bleftwords(trialindex, index), 'win', mainwin, ...
                        'sx', bleftx(trialindex, index), 'sy', blefty(trialindex, index), ...
                        'xalign', 'center', 'yalign', 'center', 'xlayout', 'center', 'baseColor', black);
                    DrawFormattedText2(brightwords(trialindex, index), 'win', mainwin, ...
                        'sx', brightx(trialindex, index), 'sy', brighty(trialindex, index), ...
                        'xalign', 'center', 'yalign', 'center', 'xlayout', 'center', 'baseColor', black);
                end

                % center_text(mainwin, wordList{trialorder(i)}, colorList(trialorder(i),1:3), 0);
                [StimulusOnsetTime] = Screen('Flip', mainwin);
                %
                %         pp(uint8(pinnums),mylogs{stimcodes(trialorder(i))},false,uint8(0),pportaddress);
                %         WaitSecs(cleartime);
                %         pp(uint8(pinnums),[0 0 0 0 0 0 0 0],false,uint8(0),pportaddress);

                %%% present on screen for duration of dur1

                timeStart = StimulusOnsetTime;
                keyIsDown = 0;
                rt = 0;
                keypressed = 0;
                presscounter = 0;

                % find different way to log response time
                while GetSecs - timeStart <= dur1
                    [keyIsDown, secs, keyCode] = KbCheck;
                    FlushEvents('keyDown');

                    if presscounter == 0 % protect against recording of multiple key responses

                        if keyIsDown
                            nKeys = sum(keyCode);

                            if nKeys == 1

                                if keyCode(Key1) || keyCode(Key2)
                                    %                                pp(uint8(pinnums),mylogs{respcode},false,uint8(0),pportaddress);
                                    %                                WaitSecs(cleartime);
                                    %                                pp(uint8(pinnums),[0 0 0 0 0 0 0 0],false,uint8(0),pportaddress);

                                    rt = 1000 .* (GetSecs - timeStart);
                                    keypressed = find(keyCode);
                                    presscounter = 1;
                                    continue
                                elseif keyCode(pauseKey) % if pause key
                                    paused = 1;
                                    DrawFormattedText2('Experiment paused.', 'win', mainwin, 'sx', RectWidth(screenrect) / 2, 'sy', RectHeight(screenrect) / 2, ...
                                        'xalign', 'center', 'yalign', 'center', 'xlayout', 'center', 'baseColor', black);
                                    Screen('Flip', mainwin);
                                    keyIsDown = 0;

                                    while 1 % check if hit key after hit pause
                                        [keyIsDown, secs, keyCode] = KbCheck;

                                        if keyIsDown

                                            if keyCode(continueKey) % continue then break loop and continue
                                                break
                                            elseif keyCode(escKey) % escape then close experiment
                                                output_table = cell2table(output_cell, "VariableNames", header);
                                                writetable(output_table, filename, 'Sheet', 1)
                                                ShowCursor;
                                                fclose(outfile);
                                                Screen('CloseAll');
                                                return
                                            end

                                        end

                                    end

                                    break; % check if necessary
                                elseif keyCode(escKey) % if escape key close experiment
                                    output_table = cell2table(output_cell, "VariableNames", header);
                                    writetable(output_table, filename, 'Sheet', 1)
                                    ShowCursor; fclose(outfile); Screen('CloseAll');
                                    return
                                end

                                keyIsDown = 0; keyCode = 0;
                            end

                        end

                    end

                end

                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%% PHASE 3 - RETENTION (FIXATION ONLY) %%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

                %%% draw fixation
                DrawFormattedText2('+', 'win', mainwin, 'sx', RectWidth(screenrect) / 2, 'sy', ...
                RectHeight(screenrect) / 2, 'xalign', 'center', 'yalign', 'center', ...
                    'xlayout', 'center', 'baseColor', redColor)
                [RetentionOnsetTime] = Screen('Flip', mainwin);
                time2 = RetentionOnsetTime;

                %%% present on screen for duration of value at
                %%% bretentionDuration(trialindex) - from trialdata.csv and
                %%% range from .9 to 1.1

                while GetSecs - time2 <= bretentionDuration(trialindex)
                    [keyIsDown, secs, keyCode] = KbCheck;
                    FlushEvents('keyDown');

                    if presscounter == 0 % protect against overwriting previous response

                        if keyIsDown
                            nKeys = sum(keyCode);

                            if nKeys == 1

                                if keyCode(Key1) || keyCode(Key2)
                                    %                                pp(uint8(pinnums),mylogs{respcode},false,uint8(0),pportaddress);
                                    %                                WaitSecs(cleartime);
                                    %                                pp(uint8(pinnums),[0 0 0 0 0 0 0 0],false,uint8(0),pportaddress);

                                    rt = 1000 .* (GetSecs - timeStart);
                                    keypressed = find(keyCode);
                                    presscounter = 1;
                                    continue
                                elseif keyCode(pauseKey) % if pause key
                                    paused = 1;
                                    DrawFormattedText2('Experiment paused.', 'win', mainwin, 'sx', RectWidth(screenrect) / 2, 'sy', RectHeight(screenrect) / 2, ...
                                        'xalign', 'center', 'yalign', 'center', 'xlayout', 'center', 'baseColor', black);
                                    Screen('Flip', mainwin);
                                    keyIsDown = 0;

                                    while 1 % check if hit key after hit pause
                                        [keyIsDown, secs, keyCode] = KbCheck;

                                        if keyIsDown

                                            if keyCode(continueKey) % continue then break loop and continue
                                                break
                                            elseif keyCode(escKey) % escape then close experiment
                                                output_table = cell2table(output_cell, "VariableNames", header);
                                                writetable(output_table, filename, 'Sheet', 1)
                                                ShowCursor;
                                                fclose(outfile);
                                                Screen('CloseAll');
                                                return
                                            end

                                        end

                                    end

                                    break; % check if necessary
                                elseif keyCode(escKey) % if escape key close experiment
                                    output_table = cell2table(output_cell, "VariableNames", header);
                                    writetable(output_table, filename, 'Sheet', 1)
                                    ShowCursor; fclose(outfile); Screen('CloseAll');
                                    return
                                end

                                keyIsDown = 0; keyCode = 0;
                            end

                        end

                    end

                end

                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%% PHASE 4 - MEMORY (FIXATION AND WORDS) %%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

                %%% draw fixation
                DrawFormattedText2('+', 'win', mainwin, 'sx', RectWidth(screenrect) / 2, 'sy', RectHeight(screenrect) / 2, ...
                'xalign', 'center', 'yalign', 'center', 'xlayout', 'center', 'baseColor', redColor)

                %%% check if should be same or different
                if (bisSame(trialindex) == 1) %if same
                    %%% display same words
                    %%% create subword and test arr
                    wordtosub = bsubword(trialindex);
                    testarr = ["nan" "nan" "nan"];

                    for index = 1:a
                        %%% draw words until condition number
                        DrawFormattedText2(bleftwords(trialindex, index), 'win', mainwin, ...
                        'sx', bleftx(trialindex, index), 'sy', blefty(trialindex, index), ...
                            'xalign', 'center', 'yalign', 'center', 'xlayout', 'center', 'baseColor', black);
                        DrawFormattedText2(brightwords(trialindex, index), 'win', mainwin, ...
                            'sx', brightx(trialindex, index), 'sy', brighty(trialindex, index), ...
                            'xalign', 'center', 'yalign', 'center', 'xlayout', 'center', 'baseColor', black);
                    end

                elseif (bisSame(trialindex) == 2) % if different
                    %%% change by one word, replace with substitute word
                    %retrieve word from subword column
                    wordtosub = bsubword(trialindex);
                    randpos = randi([1, a], 1); %get random position 1 to condition number to replace
                    testarr = [];

                    %%% if changes at left
                    if (bwhichDirection(trialindex) == 1)
                        % make array to replace one side
                        testarr = bleftwords(trialindex, :);
                        % replace word at random location with sub word
                        testarr(randpos) = wordtosub;

                        % draw words
                        for index = 1:a
                            %%% draw words until condition number - using
                            %%% test array for left
                            DrawFormattedText2(testarr(:, index), 'win', mainwin, ...
                            'sx', bleftx(trialindex, index), 'sy', blefty(trialindex, index), ...
                                'xalign', 'center', 'yalign', 'center', 'xlayout', 'center', 'baseColor', black);
                            DrawFormattedText2(brightwords(trialindex, index), 'win', mainwin, ...
                                'sx', brightx(trialindex, index), 'sy', brighty(trialindex, index), ...
                                'xalign', 'center', 'yalign', 'center', 'xlayout', 'center', 'baseColor', black);
                        end

                        %%% if changes at right
                    elseif (bwhichDirection(trialindex) == 2)
                        % make array to replace one side
                        testarr = brightwords(trialindex, :);
                        testarr(randpos) = wordtosub; % replace word at random location with sub word
                        % draw words
                        for index = 1:a
                            %%% draw words until condition number - using
                            %%% test array for right
                            DrawFormattedText2(bleftwords(trialindex, index), 'win', mainwin, ...
                            'sx', bleftx(trialindex, index), 'sy', blefty(trialindex, index), ...
                                'xalign', 'center', 'yalign', 'center', 'xlayout', 'center', 'baseColor', black);
                            DrawFormattedText2(testarr(:, index), 'win', mainwin, ...
                                'sx', brightx(trialindex, index), 'sy', brighty(trialindex, index), ...
                                'xalign', 'center', 'yalign', 'center', 'xlayout', 'center', 'baseColor', black);
                        end

                    end

                end

                %%% collect responses

                [TestArrayOnsetTime] = Screen('Flip', mainwin);
                time3 = TestArrayOnsetTime; t2wait = dur2;
                % wait 2 seconds max to retrieve response, then move on
                ListenChar(2);

                tStart = GetSecs; timedout = false;
                rsp.RT = NaN; rsp.keyCode = []; rsp.keyName = []; rsp.acc = nan;

                while ~timedout
                    % check if a key is pressed
                    % only keys specified in activeKeys are considered valid
                    [keyIsDown, keyTime, keyCode] = KbCheck;
                    if (keyIsDown), break; end
                    if ((keyTime - tStart) > t2wait), timedout = true; end
                end

                % store code for key pressed and reaction time
                if (~timedout)
                    rsp.RT = keyTime - tStart;
                    rsp.keyCode = keyCode;
                    rsp.keyName = KbName(rsp.keyCode);
                end

                % if the wait for presses is in a loop,
                % then the following two commands should come after the loop finishes
                % reset the keyboard input checking for all keys
                % re-enable echo to the command line for key presses
                % if code crashes before reaching this point
                % CTRL-C will reenable keyboard input

                %%% Get accuracy of trial
                if (KbName(rsp.keyCode))

                    if (KbName(rsp.keyCode) == "LeftArrow") % if left arrow press

                        if (bisSame(trialindex) == 1) % if same
                            totalcorr = totalcorr + 1;
                            blockcorr = blockcorr + 1;
                            rsp.acc = 1;
                        elseif (bisSame(trialindex) == 2)

                            if (totalcorr ~= 0)
                                totalcorr = totalcorr + 0;
                                blockcorr = blockcorr + 0;
                            else
                                totalcorr = 0;
                            end

                            rsp.acc = 0;
                        end

                    elseif (KbName(rsp.keyCode) == "RightArrow")

                        if (bisSame(trialindex) == 1)

                            if (totalcorr ~= 0)
                                totalcorr = totalcorr + 0;
                                blockcorr = blockcorr + 0;
                            else
                                totalcorr = 0;
                            end

                            rsp.acc = 0;
                        elseif (bisSame(trialindex) == 2)
                            totalcorr = totalcorr + 1;
                            blockcorr = blockcorr + 1;
                            rsp.acc = 1;
                        end

                    end

                else
                    totalcorr = totalcorr + 0;
                    blockcorr = blockcorr + 0;
                    rsp.acc = 0;
                    rsp.RT = {'nan'};
                    rsp.keyName = {'nan'};
                end

                %%% zone's code from before, check comments below at end of
                %%% file

                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%% OUTPUT DATA %%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

                acc = totalcorr / logindex;
                disp('###################### WORDS #############################################')
                %%% process data for logging
                leftword1 = bleftwords(trialindex, 1); leftword2 = bleftwords(trialindex, 2); leftword3 = bleftwords(trialindex, 3);
                rightword1 = brightwords(trialindex, 1); rightword2 = brightwords(trialindex, 2); rightword3 = brightwords(trialindex, 3);
                testword1 = testarr(1, 1); testword2 = testarr(1, 2); testword3 = testarr(1, 3);

                leftword1 = char(leftword1); leftword2 = char(leftword2); leftword3 = char(leftword3);
                rightword1 = char(rightword1); rightword2 = char(rightword2); rightword3 = char(rightword3);
                testword1 = char(testword1); testword2 = char(testword2); testword3 = char(testword3);

                row = [subid version a blockNum nTrialsPerBlock logindex bisSame(trialindex) bwhichDirection(trialindex) bretentionDuration(trialindex) rsp.RT rsp.acc Instruct1OnsetTime ConditionInstructOnsetTime FixationOnsetTime StimulusOnsetTime TestArrayOnsetTime leftword1 leftword2 leftword3 rightword1 rightword2 rightword3 testword1 testword2 testword3 wordtosub acc indexindata rsp.keyName];
                output_cell(logindex, :) = row;
                blockindex = blockindex + 1; logindex = logindex + 1; indexindata = indexindata +1; %index up values at end of trial
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%% END OF A SINGLE TRIAL %%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            end

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%% END OF A SINGLE BLOCK %%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%% If 'S' Version for Testing %%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if (version == 'S')
                %%% display accuracy for block
                DrawFormattedText2(sprintf('Accuracy: %d percent. Press space to continue.', (blockcorr / nTrialsPerBlock) * 100), 'win', mainwin, ...
                'sx', RectWidth(screenrect) / 2, 'sy', RectHeight(screenrect) / 2, 'xalign', 'center', ...
                    'yalign', 'center', 'xlayout', 'center', 'baseColor', black);
                [~, AccuracyBlock] = Screen('Flip', mainwin);

                keyIsDown = 0;

                while 1
                    [keyIsDown, secs, keyCode] = KbCheck;

                    if keyIsDown

                        if keyCode(pauseKey) % if pause key
                            paused = 1;
                            DrawFormattedText2('Experiment paused.', 'win', mainwin, 'sx', RectWidth(screenrect) / 2, 'sy', RectHeight(screenrect) / 2, ...
                                'xalign', 'center', 'yalign', 'center', 'xlayout', 'center', 'baseColor', black);
                            Screen('Flip', mainwin);
                            keyIsDown = 0;

                            while 1 % check if hit key after hit pause
                                [keyIsDown, secs, keyCode] = KbCheck;

                                if keyIsDown

                                    if keyCode(continueKey) % continue then break loop and continue
                                        break
                                    elseif keyCode(escKey) % escape then close experiment
                                        output_table = cell2table(output_cell, "VariableNames", header);
                                        writetable(output_table, filename, 'Sheet', 1)
                                        ShowCursor;
                                        fclose(outfile);
                                        Screen('CloseAll');
                                        return
                                    end

                                end

                            end

                            break; % check if necessary
                        elseif keyCode(spaceKey) % no pause key just continue
                            break
                        elseif keyCode(escKey) % no pause key just escape
                            output_table = cell2table(output_cell, "VariableNames", header);
                            writetable(output_table, filename, 'Sheet', 1)
                            ShowCursor;
                            fclose(outfile);
                            Screen('CloseAll');
                            return
                        end

                    end

                end

            end

        end

        count = count + 1;

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%% END OF A SINGLE CONDITION %%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    end

    output_table = cell2table(output_cell, "VariableNames", header);
    writetable(output_table, filename, 'Sheet', 1)

    Screen('CloseAll');
    fclose(outfile);
    fprintf('\n\n\n\n\nFINISHED this part! PLEASE GET THE EXPERIMENTER...\n\n');

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%% END OF EXPERIMENT %%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%

    %%% Zone's code from before

    %         %%% create a variable to log trial correctness
    %         if (keypressed==corrkey(1)&&colorValue(trialorder(i))==5)||(keypressed==corrkey(2)&&colorValue(trialorder(i))==6)
    %            correct(i)=1;
    % %           pp(uint8(pinnums),mylogs{correctcode},false,uint8(0),pportaddress);
    % %           WaitSecs(cleartime);
    % %           pp(uint8(pinnums),[0 0 0 0 0 0 0 0],false,uint8(0),pportaddress);
    %         else
    %            correct(i)=0;
    % %           pp(uint8(pinnums),mylogs{incorrectcode},false,uint8(0),pportaddress);
    % %           WaitSecs(cleartime);
    % %           pp(uint8(pinnums),[0 0 0 0 0 0 0 0],false,uint8(0),pportaddress);
    %         end
    %
    %         %%% create a variable so that word list category can be logged
    %         if trialorder(i) < 17
    %             listName = 'related';  % listName, which word list is the word from
    %         elseif trialorder(i) < 33
    %             listName = 'negative';
    %         elseif trialorder(i) < 49
    %             listName = 'positive';
    %         else listName = 'neutral';
    %         end
    %
    %         %%% create a variable to log accumulative percentage correct
    %         accPerCorrect=100*sum(correct(1:i))/i;
    %
    %         %%% create a variable to log accumulative trial number
    %         accTrialNum = i + 64*(a-1);
    %
    %         %%% write data out: s=string; d=double(integers); f=float; \t=put a tab; \n=return to next line
    %          % fprintf(outfile, '%s\t %s\t %d\t %d\t %d\t %s\t %s\t %s\t %d\t %d\t %d\t %d\t %6.2f\t \n',...
    %                            % subid, version, a, i, accTrialNum, wordList{trialorder(i)}, wordColor{trialorder(i)}, listName, keypressed, correct(i), accPerCorrect, paused, rt);
