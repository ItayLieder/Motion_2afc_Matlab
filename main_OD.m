% function main_OD()

%{
Moving dots 2AFC orientation discrimination task
100% coherence of motion for two consecutive stimuli, the subject has to detect -
the change in orientation – clockwise or anticlockwise.
%}

%%%%%%%%%%%%%%%%%%%%%%%%%
% any preliminary stuff
%%%%%%%%%%%%%%%%%%%%%%%%%
% check for Opengl compatibility, abort otherwise:
AssertOpenGL;

% Clear Matlab/Octave window and workspace:
clc;
clear;

global w rect black gray white rmax rmin s fps ppd fix_cord ifi center

%%%%%%%%%%%%%%%%%%%%%%%%
% Parameters definition
%%%%%%%%%%%%%%%%%%%%%%%%

nTrials = 200; % number of total trials
break_every = 50; % so break every x trials

maxRT = 20; % maximum wait time for response
stimulus_duration = 800;
nrange = [500,1000];
ISI = 1000; % noise between stimuli

% ------------------------
% sampling method
% ------------------------

% method = 'uniform';
method = 'unimodal';
% method = 'bimodal';
% method = '4modal';

mu1 = pi/4; % mean of the gaussian (deg)
dfrange = [2*pi/50,2*pi/40]; % difficulty from - to (uniformly)


% ------------------------
% set dot field parameters
% ------------------------
ndots = 400; % number of dots (according to density)
f_kill = 0.25; % fraction of dots to kill each frame (limited lifetime)
dot_speed = 6; % (deg/sec)

ratio = unitsratio('cm','inch');
set(0,'units','inches')
screen_size=ratio.*get(0,'screensize');

mon_width   = screen_size(3);   % horizontal dimension of viewable screen (cm)
max_d       = screen_size(4)/2;   % maximum radius of  annulus (degrees)
min_d       = 1;    % minumum
dot_w       = 0.18;  % width of dot (deg)
fix_r       = 0.15; % radius of fixation point (deg)
v_dist      = 52;   % viewing distance (cm)

% ------------------------
% init results variables
% ------------------------
rt = nan(nTrials,1);
resp = nan(nTrials,1);
acc = nan(nTrials,1);

s1 = zeros(nTrials,1);
s2 = zeros(nTrials,1);
mu2 = []; mu3 =[]; mu4 =[];
mu = [];

%%%%%%%%%%%%%%%%%%%%%%%%%
% Regsiter participant
%%%%%%%%%%%%%%%%%%%%%%%%%

prompt = {'Subject name:','Session number:'};
title = 'FD X ranges';
lines = 1;
def = {'XXXX9999','1','f'};
answer = inputdlg(prompt,title,lines,def);
if ~isempty(answer)
    subName = answer{1};
    session = str2double(answer{2});
else
    clear
end

%%%%%%%%%%%%%%%%%%%%%%
% Keyboard
%%%%%%%%%%%%%%%%%%%%%%

% Make sure keyboard mapping is the same on all supported operating systems
% Apple MacOS/X, MS-Windows and GNU/Linux:
KbName('UnifyKeyNames');

% Init keyboard responses (caps doesn't matter)
% eliminate the second sign in order to use the num pad keys
firstToneResp = KbName('1');
secondToneResp = KbName('2');

firstToneResp = KbName('z');
secondToneResp = KbName('x');

quitKey = KbName('ESCAPE');

%%%%%%%%%%%%%%%%%%%%%%
% File handling
%%%%%%%%%%%%%%%%%%%%%%

% Define filenames of input files and result file:
datafilename = strcat('MD_',subName,'_',num2str(session),'.mat'); % name of data file to write to

% check for existing result file to prevent accidentally overwriting
fileExist = dir(datafilename);
if ~strcmp(subName,'XXXX9999') && session > 0 && size(fileExist,1) > 0
    error('Result data file already exists! Choose a different subject number or session.');
end

% save results in .mat format
save(datafilename,'rt','s1','s2','resp','acc','mu');
%%
%%%%%%%%%%%%%%%%%%%%
% Stimuli sampling
%%%%%%%%%%%%%%%%%%%%

%{
P(s1):
Uniform - s1 is sampled unifomrly
Unimodal - s1 is sampled gaussian with mean mu1
Bimodal - s1 is sampled gaussian bimodal mixture with means mu1 and m2 = mu1 + pi; 
4-modal - s1 is sampled gaussian 4 modals mixtures with means - m1,m1+pi,m1+pi/2,m1+pi*3/2
%}

if strcmp(method,'uniform')
    % mu remains empty
elseif strcmp(method,'unimodal')
elseif strcmp(method,'bimodal')
    mu2 = mu1+pi;
elseif strcmp(method,'4modal')
    mu2 = mu1+pi;
    mu3 =mu1+pi/2;
    mu4 = mu3+pi;
end

mu = [mu1,mu2,mu3,mu4];
mu = mod(mu,2*pi);


for ii = 1:nTrials
    [s1(ii),s2(ii)] = drawNewTrial_OD(dfrange,method,mu);
end
%%
%%%%%%%%%%%%%%%%%%%%%%
% Screen
%%%%%%%%%%%%%%%%%%%%%%

try
    
    Screen('Preference', 'SkipSyncTests', 1);
    
    screens=Screen('Screens');
    screenNumber=max(screens);
    
    % Hide the mouse cursor and supress output in command window:
    HideCursor;
    ListenChar(2)
    commandwindow
    
    % Returns as default the mean gray value of screen:
    gray = GrayIndex(screenNumber);
    black = BlackIndex(screenNumber);
    white = WhiteIndex(screenNumber);
    
    [w, rect] = Screen('OpenWindow', screenNumber, black);
    
    % Enable alpha blending with proper blend-function. We need it
    % for drawing of smoothed points:
    Screen('BlendFunction', w, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    [center(1), center(2)] = RectCenter(rect);
    fps = Screen('FrameRate',w);      % frames per second
    ifi = Screen('GetFlipInterval', w);
    if fps==0
        fps = 1/ifi;
    end;
    
    Priority(MaxPriority(w));
    
    Screen('TextFont',w,'Arial');
    Screen('TextSize', w, 32);
    
    % Set priority for script execution to realtime priority:
    priorityLevel=MaxPriority(w);
    Priority(priorityLevel);
    
    
    cd('img')
    img=imread('MD2.jpg');
    inst = Screen('MakeTexture', w, img);
    cd('..')
    %%
    % ---------------------------------------------
    % initialize dot positions and velocities
    % ---------------------------------------------
    
    ppd = pi * (rect(3)-rect(1)) / atan(mon_width/v_dist/2) / 360;    % pixels per degree
    s = dot_w * ppd;                                        % dot size (pixels)
    fix_cord = [center-fix_r*ppd center+fix_r*ppd];
    
    rmax = max_d * ppd;	% maximum radius of annulus (pixels from center)
    rmin = min_d * ppd; % minimum
    %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %====== Instructions =======
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    instCELL_break{1,1}='Block is finished';
    instCELL_break{1,2}='\n \n Take a few seconds to freshen up';
    instCELL_break{1,3}='\n \n When ready, press "space" to continue to the next blcok';
    
    instCELL_start{1,1}='Press 2 if the change in motion goes clockwise';
    instCELL_start{1,2}='\n \n Press 1 if the change in motion goes anti-clockwise';
    instCELL_start{1,3}='\n \n Please respond as quickly as possible -';
    instCELL_start{1,4}='\n \n - after spoting the two consecutive motions';
    instCELL_start{1,5}='\n \n Press any key to continue';
    
    %%%%%%%%%%%%%%%%%%%%%%
    % experiment
    %%%%%%%%%%%%%%%%%%%%%%
    
    % Do dummy calls to GetSecs, WaitSecs, KbCheck to make sure
    % they are loaded and ready when we need them - without delays
    % in the wrong moment:
    [KeyIsDown, KeyTime, KeyCode]=KbCheck;
    feedbackOffset = GetSecs;
    
    for tt = 1:nTrials
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%
        % Start/Break
        %%%%%%%%%%%%%%%%%%%%%%%%%%
        if mod(tt,break_every)==1
            % display instructions
            if tt==1
                playInstructions( instCELL_start );
            else
                playInstructions( instCELL_break );
            end
        end
        
        if KeyCode(quitKey)==1
            error('aborted by user');
        end
        
        %%
        %%%%%%%%%%%%%%%%
        % PRESENTATION
        %%%%%%%%%%%%%%%%
        onset = GetSecs;
        noise_duration_pre = rand()*(nrange(2)-nrange(1)) + nrange(1); % noise before first stimulus

        % Pre-interval noise
        noise = 1;
        show_motion(ndots,f_kill,0,dot_speed,noise,noise_duration_pre)
        % First-interval
        noise = 0;
        show_motion(ndots,f_kill,s1(tt),dot_speed,noise,stimulus_duration)
        % ISI noise
        noise = 1;
        show_motion(ndots,f_kill,0,dot_speed,noise,ISI)
        % Second-interval
        noise = 0;
        show_motion(ndots,f_kill,s2(tt),dot_speed,noise,stimulus_duration)
        
        Screen('DrawTexture', w, inst, [], rect);
        Screen('Flip', w);
        %%
        [KeyIsDown, respTime, KeyCode]=KbCheck;
        
        while KeyCode(firstToneResp)==0 && KeyCode(secondToneResp)==0 ...
                && KeyCode(quitKey)==0 && (respTime - onset) < maxRT
            [KeyIsDown, respTime, KeyCode]=KbCheck;
        end
        
        if KeyCode(quitKey)==1
            error('aborted by user')
        end
        
        % compute response time
        if sum(KeyCode) ==1 && (KeyCode(firstToneResp)==1 || KeyCode(secondToneResp)==1)
            rt(tt)=1000*(respTime-onset);
            resp(tt) = KbName(KeyCode);
        else
            resp(tt) = '_';
        end
        
        
        % save results in .mat format
        resp(resp==50)=1;
        resp(resp==49)=0;
        acc = resp==(s1>s2);
        
        save(datafilename,'rt','s1','s2','resp','acc','mu');
    end % for trial loop
    %%%%%%%%%%%%%%%%%%%%%%
    % experiment end
    %%%%%%%%%%%%%%%%%%%%%%
    Screen('TextSize', w, 32);
    
    message = 'thank you for participating';
    DrawFormattedText(w, message, 'center', 'center', white);
    
    % Update the display to show the farewell text:
    Screen('Flip', w);
    
    WaitSecs(2);
    
    % Cleanup at end of experiment - Close window, show mouse cursor, close
    % result file, switch Matlab/Octave back to priority 0 -- normal
    % priority:
    Screen('CloseAll');
    ShowCursor;
    fclose('all');
    Priority(0);
    clc
    ListenChar(0)
    clear;
    % End of experiment:
    return;
catch ME
    % catch error: This is executed in case something goes wrong in the
    % 'try' part due to programming error etc.:
    save(strcat(num2str(clock,'%4.0f'),' wksp.mat')) % save workspace for debuging purpose
    % Do same cleanup as at the end of a regular session...
    Screen('CloseAll');
    ShowCursor;
    fclose('all');
    Priority(0);
    ListenChar(0)
    close all
    rethrow(ME)
    clear;
end % try ... catch %