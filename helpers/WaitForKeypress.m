function [key time] = WaitForKeypress(timeout)
% [key time] = WaitForSubject(timeout)
% 
% NOTE: Requires KbQueue to be set up correctly beforehand!!
% 
% INPUTS:
% timeout (optional) - in seconds, relative to time of function call
% 
% OUTPUTS:
% key - NaN if timeout
% time - from GetSecs. NaN if timeout

global INPUTS

if exist('timeout','var')
    % set timeout relative to start time
    timeout = timeout + GetSecs;
else
    timeout = Inf;
end

key = nan;
time = nan;

KbQueueFlush;
while GetSecs < timeout
    
    WaitSecs(0.005);
    [keyispressed firstPress firstRelease lastPress lastRelease] = KbQueueCheck;
    
    if (keyispressed ==1) %if a button was pressed
        key = find(firstPress(INPUTS.buttons),1);
        time = GetSecs;
        break;
    end
end
end