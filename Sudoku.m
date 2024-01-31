clear
close
clc

%% Sudoku Open-Source Code
% Created by Caden Burklund & Korey Closson

%% Guided User Interface
% This creates the pop-up that the game will be played in:
    window = figure('position', [0 0 400 500],...
                    'unit','pixels',...
                    'name','Sudoku',...
                    'visible','on');
% This will allow us to choose the location of the pop-up window:
    movegui(window,'center');

%% Create & Organize Cells
% Sudoku is a 9x9 matrix, subdivided into 9 3x3 matrices.
% Set parameters for the cells:
    CornerX = 38; % Shifts the matrix left or right.
    CornerY = 410; % Shifts the matrix up or down.
    dx = 35; % Stretches cells left or right.
    dy = 35; % Stretches cells up or down.
    groupGap = 5; % Gap between 9 subdivided matrices.
% Create the Cells with a Nested For-Loop
    for ii = 1:9
       for jj = 1:9
           % Design the cells and their placement:
           xPos = CornerX + (jj-1)*dx + floor((jj-1)/3) * groupGap;
           yPos = CornerY - (ii-1)*dy - floor((ii-1)/3) * groupGap;
           sudokugui.X(ii,jj) = uicontrol...
               ('unit','pixels',...
                'background',[1, 1, 1],...
                'style','edit',...
                'visible','on',...
                'position',[xPos, yPos, dx, dy],...
                'fontsize',14',...
                'fontweight','normal',...
                'enable','on',...
                'KeyPressFcn',{@cbEntry,window,ii,jj});
       end
    end

%% Title Sprite
% Any png image can be used as the sprite for their title:
    spritePath = 'InsertSprite.png';
    spriteImage = imread(spritePath, 'BackgroundColor',[1 1 1]);
% Create an axes to display the sprite
    spriteAxes = axes('unit', 'pixels', 'position', [0, 455, 400, 50]);
    imshow(spriteImage, 'Parent', spriteAxes, 'InitialMagnification', 'fit');
% Remove axis ticks and labels
    axis(spriteAxes, 'off');


%% Buttons
% "Generate Random Puzzle" Button
    sudokugui.generateButton = uicontrol...
   ('Style', 'pushbutton',...
    'Units', 'pixels',...
    'Position', [70, 50, 140, 40],...
    'String', 'Generate Random Puzzle',...
    'FontSize', 8,...
    'FontWeight', 'bold',...
    'Callback', {@generateRandomPuzzle, sudokugui});

% "Check for Win" Button
    sudokugui.checkForWinButton = uicontrol...
   ('Style', 'pushbutton',...
    'Units', 'pixels',...
    'Position', [220, 50, 80, 40],...
    'String', 'Check for Win',...
    'FontSize', 8,...
    'FontWeight', 'bold',...
    'Callback', {@checkForWinButtonCallback, sudokugui});

%% Callback & Helper Functions

% Call function when "Check for Win" is clicked
    function checkForWinButtonCallback(~, ~, sudokugui)
        % Extract values from the GUI
        sudokuMatrix = getMatrixFromGUI(sudokugui.X);
        % Check for a Win
        if isSudokuSolutionValid(sudokuMatrix)
            % If true, then print message for winners
            msgbox('Congratulations! We''re proud of you!', 'Winner', 'help');
        else
            % If false, prompt user to continue trying
            msgbox('Keep Trying!', 'Try Again', 'warn');
        end
    end

% Get's current matrix from GUI and represents it numerically
    function sudokuMatrix = getMatrixFromGUI(X)
    % Initialize matrix with zeros
        sudokuMatrix = zeros(9);
        % Iterate through each index with nested for-loop
        for ii = 1:9
            for jj = 1:9
                % Get value at index
                value = get(X(ii, jj), 'String');
                if ~isempty(value)
                    sudokuMatrix(ii, jj) = str2double(value);
                end
            end
        end
    end

% Check for Validity of the Sudoku Solution
    function isValid = isSudokuSolutionValid(sudokuMatrix)
    % Check rows
        isValidRows = all(arrayfun(@(row) numel(unique(row)) == numel(row) - sum(row == 0), sudokuMatrix));
    % Check columns
        isValidCols = all(arrayfun(@(col) numel(unique(col)) == numel(col) - sum(col == 0), sudokuMatrix'));
    % Check 3x3 Subgrids
        isValidSubgrids = true;
        for i = 1:3:9
            for j = 1:3:9
                subgrid = sudokuMatrix(i:i+2, j:j+2);
                subgridValues = subgrid(:);
                isValidSubgrids = isValidSubgrids && all(arrayfun(@(num) sum(subgridValues == num) <= 1, subgridValues(subgridValues ~= 0)));
            end
        end
    % If each boolean evaluates to true, then the solution is valid
        isValid = isValidRows & isValidCols & isValidSubgrids;
    end

%% Get User's Key Press
    function cbEntry(src, event, ~, ~, ~)
    % Get the entered key
       key = event.Key;
       % Get the current content of the edit box
       currentContent = get(src, 'String');
       % Check if the entered key is a valid digit
       validDigits = {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9'};
       if isempty(currentContent) && ismember(key, validDigits)
           % Update the edit box with the entered key
           set(src, 'String', key);
       elseif length(currentContent) == 1 && ismember(key, validDigits)
           % Concatenate the current content with the entered key
           newContent = [currentContent, key];
           % Check if the resulting number is in the valid range (1-9)
           if str2double(newContent) >= 1 && str2double(newContent) <= 9
               % Update the edit box with the entered key
               set(src, 'String', newContent);
           else
               % Display a message for invalid input
               msgbox('Invalid input. Please enter a number between 1 and 9.', 'Error', 'error');
               % Clear the content of the edit box for invalid input
               set(src, 'String', '');
           end
       elseif strcmp(key, 'backspace')
           % Check if the entered key is 'backspace' (delete functionality)
           % Remove the last character from the content
           set(src, 'String', currentContent(1:end-1));
       else
           % Display a message for invalid input
           msgbox('Invalid input. Please enter a number between 1 and 9.', 'Error', 'error');
           % Clear the content of the edit box for invalid input
           set(src, 'String', '');
       end
    end

%% Random Number Generator

% Generate Random Puzzle
   function generateRandomPuzzle(~, ~, sudokugui)
   % Clear existing puzzle
       for ii = 1:9
           for jj = 1:9
               set(sudokugui.X(ii,jj), 'String', '', 'ButtonDownFcn', [],...
                   'BackgroundColor', 'w'); % Numbers correspond to RGB Values (White)
           end
       end 
   % Generate accurate Sudoku puzzle
       puzzle = zeros(9);
   % Fill the main diagonal of the puzzle with random numbers
       puzzle = fillDiagonal(puzzle); 
   % Solve the puzzle to get a valid solution
       solvedPuzzle = solveSudoku(puzzle);
   % Remove numbers to create the puzzle
       puzzle = createPuzzle(solvedPuzzle, 54); % Set the number of pre-filled cells  
   % Update GUI with generated puzzle
       for ii = 1:9
           for jj = 1:9
               if puzzle(ii, jj) > 0
                   % Set the value and appearance for pre-filled cells
                   set(sudokugui.X(ii, jj), 'String', num2str(puzzle(ii, jj)), 'ButtonDownFcn', [],...
                   'BackgroundColor', [0.6 0.6 0.8]); % Numbers correspond to RGB Values (Purple)
               else
                   set(sudokugui.X(ii, jj), 'String', '', 'ButtonDownFcn', [],...
                   'BackgroundColor', 'w'); % Numbers correspond to RGB Values (White)
               end
           end
       end
   end

% Fills main diagonal with random numbers
    function puzzle = fillDiagonal(puzzle)
       values = randperm(9);
       for i = 1:9
           puzzle(i, i) = values(i);
       end
    end

% Find a valid solution for the puzzle
    function solvedPuzzle = solveSudoku(puzzle)
    % Find all indices of empty cells
       emptyCells = find(puzzle == 0);
       % If there are no empty cells then puzzle is solved
       if isempty(emptyCells)
           solvedPuzzle = puzzle;
           return;
       end  
       % Find location of first empty cell
       [row, col] = ind2sub(size(puzzle), emptyCells(1)); 
       % Iterate through each possible move
       for num = 1:9
           % Determine if move is valid
           if isValidNumber(puzzle, row, col, num)
               % If valid, assign to empty cell
               puzzle(row, col) = num;
               % Check for more empty cells
               if isempty(find(puzzle == 0, 1))
                   % Puzzle is filled, return puzzle
                   solvedPuzzle = puzzle;
                   return;
               else
                   % Not filled, call function with current puzzle
                   tempPuzzle = solveSudoku(puzzle);
                   if ~isempty(tempPuzzle)
                       solvedPuzzle = tempPuzzle;
                       return;
                   end
               end
               % Backtrack if the current assignment leads to a dead-end
               puzzle(row, col) = 0;
           end
       end 
       % If no valid solution then return empty array
       solvedPuzzle = [];
    end


% Removes numbers from a fully solved puzzle so that the user may play it
    function puzzle = createPuzzle(solvedPuzzle, numPreFilled)
    % Initialize the puzzle with a fully filled in puzzle
        puzzle = solvedPuzzle;
    % Calculate the number of cells to remove
        numRemoved = 81 - numPreFilled;
    % Check if number of removed cells is within a valid range
        numRemoved = max(0, min(numRemoved, 80));
    % Selects random indices on the board
        emptyCells = randperm(81, numRemoved);
    % Sets those indices current value to 0
        puzzle(emptyCells) = 0;
    end

% Checks if a specific number is valid
    function valid = isValidNumber(puzzle, row, col, num)
    % Check if the number is valid in the current row
        validRow = all(puzzle(row, :) ~= num);  
    % Check if the number is valid in the current column
        validCol = all(puzzle(:, col) ~= num); 
    % Check if the number is valid in the current 3x3 group
        startRow = 3 * floor((row - 1) / 3) + 1;
        startCol = 3 * floor((col - 1) / 3) + 1;
        validGroup = all(reshape(puzzle(startRow:startRow+2, startCol:startCol+2), 1, []) ~= num);
    % The number is valid if it satisfies all conditions
        valid = validRow && validCol && validGroup;
    end
