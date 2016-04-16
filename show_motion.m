function show_motion(ndots,f_kill,direction,dot_speed,noise,duration)

%{

%}

global w white rmax rmin s fps ppd  fix_cord ifi center


waitframes = 1;     % Show new dot-images at each waitframes'th monitor refresh.
pfs = dot_speed * ppd / fps;      % dot speed (pixels/frame)                  

% change in x and y per frame (pixels)

[ xy,dxdy,r,dr ] = init_xyr(ndots,pfs,direction,noise);

colvect=white;

time_count = zeros(ndots,1);
life_span = rand(ndots,1)*6;


% --------------
% animation loop
% --------------
over = GetSecs;
start = GetSecs;

% Do initial flip...
vbl=Screen('Flip', w);

ii = 0;
while (over - start)< (duration/1000)
    ii = ii+1;
    
    if (ii>1)
        % Draw nice dots:
        Screen('FillOval', w, uint8(white), fix_cord);	% draw fixation dot (flip erases it)
        Screen('DrawDots', w, xymatrix, s, colvect, center,1);  % change 1 to 0 to draw square dots
        Screen('DrawingFinished', w); % Tell PTB that no further drawing commands will follow before Screen('Flip')
    end;
    
    xy = xy + dxdy;						% move dots
    r = r + dr;							% update polar coordinates too
    
    % check to see which dots have gone beyond the borders of the annuli
    time_count = time_count + ifi;
    %     r_out = find(life_span<time_count);	% dots to reposition
    
    r_out = find(r > rmax | r < rmin | rand(ndots,1) < f_kill);	% dots to reposition
%         r_out = find( rand(ndots,1) < f_kill);	% dots to reposition

    nout = length(r_out);
    
    if nout
        % choose new coordinates
        life_span(r_out) = rand(length(r_out),1)*6;
        time_count(r_out) = 0;
        
        [ xy(r_out,:),dxdy(r_out,:),r(r_out),dr(r_out) ] = init_xyr(length(r_out),pfs,direction,noise);
        
        
    end;
    
    xymatrix = transpose(xy);
    vbl=Screen('Flip', w, vbl + (waitframes-0.5)*ifi);
    over = GetSecs;
end;

end