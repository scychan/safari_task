function t_trigger = WaitForSkyraTrigger(devices,timeout)
% INPUTS:
% devices - need devices.scanner
% 
% OUTPUTS:
% t_trigger - returns NaN if timeout.
% 
% Will not tempt the OS into interrupting your recording if you don't mind
% starting your trial 10ms or so after the trigger wait loop

global INPUTS

if exist('timeout','var')
    timeout = GetSecs + timeout;
else
    timeout = Inf;
end

% get the current INPUTS settings
orig_buttons = INPUTS.buttons;
orig_device = INPUTS.device;

% set up KbQueue
INPUTS.buttons = KbName('=+');
INPUTS.device = devices.scanner;
set_up_keys;

% get trigger
t_trigger = NaN;
KbQueueFlush;
while GetSecs < timeout
    WaitSecs(0.010); % put a 10ms breather between queue checks
    
    if KbQueueCheck
        t_trigger = GetSecs;
        break
    end
end

% return to original KbQueue settings
INPUTS.buttons = orig_buttons;
INPUTS.device = orig_device;
set_up_keys;