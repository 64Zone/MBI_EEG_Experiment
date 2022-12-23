%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%% GENERATE TRIAL DATA %%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Visual angle calculator: https://www.sr-research.com/visual-angle-calculator/
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function T = getTrials()
    %% Initialize csv file
    filename = 'trialdata/tdata.csv';
    nTrials = 1000; % length of sheet
    wordList = {'alarm', 'group', 'taste', 'watch', 'clean', 'relax'}; % selected words

    %% initialize screen parameters
    screenheight = 1080;
    screenwidth = 1920;

%     adjustx = 0; % for x transformation
    
%%%% GET VISUAL ANGLE VALUES FOR DISPLAY AND WORD DIMENSIONS %%%%
%%% VISUAL ANGLES %%%

% visual angles calculated using resolution of 1920 x 1080, width of
% 598 mm and height 336 mm, and eye to distance 600 mm. 
% angles used are 4 degree for width, 7.3 degree for height, and
% centered at 3 degrees away

%%% ANSWERS!: Top and Bottom in px (7.3/2; 3.65) = 123.03; Left and Right
%%% of one side in px (5 for out, 168.54; 1 for in 33.63); Centered 3 away
%%% from center (3 from center, 100.96); 4 wide = 134.71; 7.3 height = 246.78

%%% WORD DIMENSIONS %%%
% Calculate dimensions of largest word

%     for word=1:length(wordList2)
%         [nx, ny, bbox] = DrawFormattedText2(wordList2(word),'win',mainwin,'sx',RectWidth(screenrect)/2,'sy',RectHeight(screenrect)/2,'xalign','center','yalign','center','xlayout','center');        
%         pixelWidth  =  bbox(3) - bbox(1) %x;
%         pixelHeight = bbox(4) - bbox(2) %y;
%         fprintf('Pixel width: %d. Pixel height %d\n', pixelWidth, pixelHeight);
%     end

%%% ANSWERS!: (54,11), (53,11), (53,10), (54,11), (53,11), (53,11)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % max w and h of words to adjust from center
    maxH = 11;
    maxW = 54;
    largestcheck = 0;
    %% Boxes to fit stimuli

%     ymindiff = maxH; % how far words must be in y
    ymindiff = 30;
    centerx = screenwidth/2; % center of screen width
    centery = screenheight/2; % center of screen height

    %%% dimensions
    boxWidth = 67.27; % 2
    boxHeight = 134.86; % 4
    %add 1 degree
    onedegree = 33.63;

    %%% bounds of top and bottom
    top = screenheight / 2 - boxHeight / 2; % middle of screen y - 3.65 degree
    bottom = screenheight / 2 + boxHeight / 2; % middle of screen y + 3.65 degree
    %%% left
    l_in = centerx - onedegree; % inside margins = center x - half width of word - 1 degree
    l_out = centerx - boxWidth; % outside margins = center x - 4 degree - 1 degree
    %%% right
    r_in = centerx + onedegree;  % inside margins = center x + half width of word + 1 degree
    r_out = centerx + boxWidth;  % outside margins = center x + 4 degree + 1 degree

    %% Preallocate
    %%% generate random 1, 2 values for isSame and randArrows
    isSame = randi ([1 2], nTrials, 1); 
    randArrows = randi ([1 2], nTrials, 1); 
    %%% generate vals between .9 and 1.1 for retentionDuration
    retentionDuration = .9 + (1.1 - .9) .* rand(nTrials, 1); 
    %%% start wordset arrays
    l_wordset = cell(nTrials, 3);
    r_wordset = cell(nTrials, 3);
    sub_wordset = cell(nTrials, 1);
    %% Random points for coordinates
    %%% left upper and lower bound x
    l_LB = [l_out, l_out, l_out];
    l_UB = [l_in, l_in, l_in];
    %%% right upper and lower bound x
    r_LB = [r_in, r_in, r_in];
    r_UB = [r_out, r_out, r_out];

    %%% both upper and lower bound y, lower is top of rect (LB2) and upper
    %%% is bottom of rect (UB2), based on magnitude not direction
    y_LB2 = [top, top, top];
    y_UB2 = [bottom, bottom, bottom];
    %%% fill x with random points between lower and upper x
    %%% left
    l_sx = rescale(rand(nTrials, 3), l_LB, l_UB, 'InputMin', 0, 'InputMax', 1);
    l_sx = round(l_sx);
    %%% right
    r_sx = rescale(rand(nTrials, 3), r_LB, r_UB, 'InputMin', 0, 'InputMax', 1);
    r_sx = round(r_sx);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% LOOP FOR FILLING LEFT Y VALUES AND ADJUSTING X %%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % We'll fill this up as we go
    l_sy = nan(nTrials, 3); 

    for i = 1:nTrials

        while true % always runs at least once
            % make a single random row
            row = rescale(rand(1, 3), y_LB2, y_UB2, 'InputMin', 0, 'InputMax', 1);

            % check if it meets our requirements
            check12 = abs(row(1) - row(2)) > ymindiff;
            check23 = abs(row(2) - row(3)) > ymindiff;
            check31 = abs(row(3) - row(1)) > ymindiff;
 
            if check12 && check23 && check31
                % If it meets our requirements, then we can stop making new
                % `row` samples
                break
            end

            % Otherwise, the while loop runs again
        end

        row = round(row);
        l_sy(i, :) = row;
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% LOOP FOR FILLING RIGHT Y VALUES AND ADJUSTING X %%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % We'll fill this up as we go
    r_sy = nan(nTrials, 3);

    for i = 1:nTrials

        while true % always runs at least once
            % make a single random row
            row = rescale(rand(1, 3), y_LB2, y_UB2, 'InputMin', 0, 'InputMax', 1);

            % check if it meets our requirements
            check12 = abs(row(1) - row(2)) > ymindiff;
            check23 = abs(row(2) - row(3)) > ymindiff;
            check31 = abs(row(3) - row(1)) > ymindiff;

            if check12 && check23 && check31
                % If it meets our requirements, then we can stop making new
                % `row` samples
                break
            end

            % Otherwise, the while loop runs again
        end

        row = round(row);
        r_sy(i, :) = row;
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% GET WORDS AND FILL SUB WORDS ARRAY %%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    for i = 1:nTrials % trials
        %%% FILL TO 4 INDICES
        l_selectedWords = datasample(wordList, 4, 'Replace', false);
        r_selectedWords = datasample(wordList, 4, 'Replace', false);

        for x = 1:3
            l_wordset{i, x} = l_selectedWords{x};
        end

        for x = 1:3
            r_wordset{i, x} = r_selectedWords{x};
        end

        %%% IF SAME FILL SUB WORD WITH NAN STRING
        if (isSame(i) == 1)
            sub_word = 'nan';
            sub_wordset{i, 1} = sub_word;
        %%% IF DIFFERENT FILL SUB WORD WITH 4TH WORD FROM WORD LIST
        elseif (isSame(i) == 2)
            %%% LEFT
            if (randArrows(i) == 1)
                sub_wordset{i, 1} = l_selectedWords{4};
            %%% RIGHT
            elseif (randArrows(i) == 2)
                sub_wordset{i, 1} = r_selectedWords{4};
            end

        end

    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% CHANGE TYPES AND OUTPUT TO TABLE %%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    l_words = cell2table(l_wordset(1:end, :), VariableNames = {'word1', 'word2', 'word3'});
    r_words = cell2table(r_wordset(1:end, :), VariableNames = {'word1', 'word2', 'word3'});

    T = table;
    T.l1cordx = l_sx(:, 1);
    T.l2cordx = l_sx(:, 2);
    T.l3cordx = l_sx(:, 3);

    T.l1cordy = l_sy(:, 1);
    T.l2cordy = l_sy(:, 2);
    T.l3cordy = l_sy(:, 3);

    T.r1cordx = r_sx(:, 1);
    T.r2cordx = r_sx(:, 2);
    T.r3cordx = r_sx(:, 3);

    T.r1cordy = r_sy(:, 1);
    T.r2cordy = r_sy(:, 2);
    T.r3cordy = r_sy(:, 3);

    T.isSame = isSame;
    T.whichDirection = randArrows;
    T.retentionDuration = retentionDuration;
    T.l_words = l_words;
    T.r_words = r_words;
    T.subWord = sub_wordset;
    T = splitvars(T);

    %%%%%%%%%%%%%%%%%%%%
    %%% WRITE TO CSV %%%
    %%%%%%%%%%%%%%%%%%%%
    writetable(T, filename);
    disp("####################################################################")
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%% END %%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%