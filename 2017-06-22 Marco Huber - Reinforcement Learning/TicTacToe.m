function results = TicTacToe

clear;
close all;
clc;

%  
humanPlayer = 1;
runs = 10;

% Define state space
state(1:9) = 0;

% Define actions
actions = 1:9;
numActions = numel(actions);

% Define rewards;
winningReward = 1;
drawReward = 0;
losingReward = 0;

% Define Q-function
Q = zeros(3,3,3,3,3,3,3,3,3,numActions);
filename = 'qValues.mat';
filename = 'qValues_learned.mat';
try
    load(filename, 'Q');
catch
end

% Define control strategy (sparse)
piControl = zeros(numActions); 

% Extract Q-learning parameters
pars.alpha = 0.85;
pars.gamma = 0.9;
pars.epsilon = 0.1;

%%%%%%%%%%%%%%%%%%%%%%%
%% Learning functions %
%%%%%%%%%%%%%%%%%%%%%%%
    function Q_Learn(state,action,newState)

    % Local abbreviation vars
    sx = state+2;
    
    old_Q = Q(sx(1), sx(2), sx(3), sx(4), sx(5), sx(6), sx(7), sx(8), sx(9), action);
    sxNew = newState+2;
    newState_Q = Q(sxNew(1), sxNew(2), sxNew(3), sxNew(4), sxNew(5), sxNew(6), sxNew(7) ,sxNew(8), sxNew(9), :);
    newState_Q = reshape(newState_Q,1,numActions);

    % Update the action-value function as defined by Q-learning
    Q(sx(1), sx(2), sx(3), sx(4), sx(5), sx(6), sx(7), sx(8), sx(9), action) = ...
        (1-pars.alpha) * old_Q + pars.alpha * (reward + pars.gamma * max(newState_Q));

    end


%% Game
h = figure('WindowStyle', 'docked');
results = zeros(1, runs);

for runIdx=1:1:runs
    draw = 0;
    
    if mod(runIdx, 100)==0
        % Display progress
        display(runIdx);
    end
    
    while gameNotFinished(state)

        % Update control strategy for current state: eps-greedy
        sx = state+2;
        availActionsInd = (state == 0);
        naa=sum(availActionsInd);
        currentStateQ = reshape(Q(sx(1), sx(2), sx(3), sx(4), sx(5), sx(6), sx(7), sx(8), sx(9), availActionsInd),1,naa);
        max_ind = find(max(currentStateQ)==currentStateQ);
        piControl = repmat(pars.epsilon / naa, 1, naa);       
        piControl(max_ind) = (1-pars.epsilon)/numel(max_ind) + pars.epsilon/naa;       

        % Choose next action;
        availActions = actions(availActionsInd);
        if ~humanPlayer
            action = availActions(drawRandomSample(piControl));
        else
            action = availActions(max_ind(randi(numel(max_ind), 1)));
        end

        % Update state - part one (AI player uses marker "1")
        oldState = state;
        state(action) = 1;

        reward = 0;

        if(gameNotFinished(state))

            availActionsInd = (state == 0);

            % Human players turn (opponent uses marker "-1"
           
            if(humanPlayer)
                plotState;
                [x,y] = ginput(1);
                oppAction = mouse2state(x,y);
%                 inputText = ['Zug eingeben (',num2str(actions(availActionsInd)),'): '];
%                 oppAction = input(inputText);
            else
                equalProbs = ones(1,sum(availActionsInd))/sum(availActionsInd);
                availActions = actions(availActionsInd);    
                oppAction = availActions(drawRandomSample(equalProbs));
            end
            state(oppAction) = -1;

            % If a winning situation has occured, the opponent has won:        
            if(somebodyHasWon(state)) 
                reward = losingReward;
            end

        else
            if(somebodyHasWon(state))
                % Game finished after AI's turn
                reward = winningReward;
            else
                reward = drawReward;
                draw = 1;
            end

        end

        % Update Q-function
        Q_Learn(oldState,action,state);
    end % of episode
    
     % Plot end board state
    if(humanPlayer)
        plotState;
        if(reward==winningReward)
            disp('AI wins!');
            plotLine(state, 1)
        end
        if(reward==losingReward && ~draw)
            disp('You win!')
            plotLine(state, -1)
        end
        if(draw)
            disp('Draw');
        end
            
        waitforbuttonpress
%         pause;
        %disp(reward);
        clf;
    end
    
    % Reset state
    state(1:9) = 0;
    
    % Save episode result
    results(runIdx) = reward;
    
end % of game

save(filename, 'Q');

%% Helper functions
    % Has somebody won the game?
    function isWinner = somebodyHasWon(state)
        rows = sum(abs(sum(reshape(state(9:-1:1),3,3)'))== 3);
        cols = sum(abs(sum(reshape(state(9:-1:1),3,3)))== 3);
        diag1 = abs(sum(state([1 5 9])))==3;
        diag2 = abs(sum(state([3 5 7])))==3;
        isWinner = (rows + cols + diag1 + diag2 > 0);
    end

    % Is game finished yet?
    function notFinished = gameNotFinished(state)
        won = somebodyHasWon(state);
        full = sum(abs(state))==9;
        notFinished = (won + full == 0);
    end

    % Draw sample from discrete probability distr.
    function sample = drawRandomSample(probDistVector)
        % Local variables
        dim = numel(probDistVector);
        % Draw random sample from uniform standard distribution
        prob = rand(1);
        % Calculate cumulative probability vector
        cumProbVec = tril(ones(dim)) * probDistVector';
        % Return discrete sample (element in interval from CDF)
        sample = sum(cumProbVec < prob ) + 1;
    end

    function state = mouse2state(x,y)
        state = floor(x) + (floor(y)-1)*3;
    end

%% Plotting function
    function plotState
        figure(h);
        hold on;
        view([0 90]);
        grid on;
        axis([1, 4 1, 4]);
        set(gca,'XTick',1:1:4);
        set(gca,'YTick',1:1:4);
        set(gca,'XTickLabel','')
        set(gca,'YTickLabel','')
        %axis off;
        for i=1:1:9
            text(mod(i-1,3) + 1.1,floor((i-1)/3) + 1.9,int2str(i))
            if(state(i) ~= 0)
                if(state(i) == 1)
                    plot(mod(i-1,3) + 1.5, floor((i-1)/3) + 1.5, '-xb', 'MarkerSize', 40, 'LineWidth', 5);
                else
                    plot(mod(i-1,3) + 1.5, floor((i-1)/3) + 1.5, '-or', 'MarkerSize', 40, 'LineWidth', 5);
                end
            end
        end
        %pause;
    end

    function plotLine(state, player)
        rows = find(sum(reshape(state, 3,3)', 2) == player*3);
        if rows; line([1 4], [rows, rows]+.5, 'Color', [0 0 0], 'LineWidth', 4); end
        cols = find(sum(reshape(state([7 8 9, 4 5 6, 1 2 3]), 3,3)') == player*3);
        if cols; line([cols, cols]+.5, [1 4], 'Color', [0 0 0], 'LineWidth', 4); end
        diag1 = sum(state([1 5 9])) == player*3;
        if diag1; line([1, 4], [1, 4], 'Color', [0 0 0], 'LineWidth', 4); end
        diag2 = sum(state([3 5 7])) == player*3;
        if diag2; line([1, 4], [4, 1], 'Color', [0 0 0], 'LineWidth', 4); end
    end

end

