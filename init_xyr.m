function [ xy,dxdy,r,dr ] = init_xyr(len,pfs,direction,noise)
%{
This function gets: number of dots, speed, direction and noise (yes or no).
returns the initialized parameters
%}
global rmax rmin

r = rmax * sqrt(rand(len,1));	% sample uniformly
r(r<rmin) = rmin;

t = 2*pi*rand(len,1);            % theta polar coordinate

if noise
    t_motion =   2*pi*rand(len,1);                     % theta polar coordinate
else
    t_motion = -1* direction*ones(len,1);                     % theta polar coordinate
end

cs_position = [cos(t), sin(t)];
cs_motion = [cos(t_motion), sin(t_motion)];
%

xy = [r r] .* cs_position;   % dot positions in Cartesian coordinates (pixels from center)
dr = pfs.*ones(len,1);                            % change in radius per frame (pixels)
dxdy = [dr dr] .* cs_motion;                       % change in x and y per frame (pixels)

end
