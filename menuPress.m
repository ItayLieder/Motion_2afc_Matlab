function [ ] = menuPress(  )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

KbName('UnifyKeyNames');
% Init keyboard responses (caps doesn't matter)
% eliminate the second sign in order to use the num pad keys
keysWanted = KbName('space');


success = 0;
while success == 0
    pressed = 0;
        [secs, kbData, deltaSecs] = KbWait(0, 2);
          if sum(kbData(keysWanted))==1
            success = 1;
            break;
          end 
end
end