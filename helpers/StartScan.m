function t_trigger = StartScan(keysets,devices)
% (1) Waits for the experimenter to press 'g' for GO.
% (2) Then waits for the scanner trigger.

global INPUTS

% get the current INPUTS settings
orig_buttons = INPUTS.buttons;
orig_device = INPUTS.device;

Screen(INPUTS.window,'Flip');
str = 'Waiting for experimenter to press ''g''...';
DrawFormattedText(INPUTS.window,str,'center','center',[255 255 255],50);
Screen(INPUTS.window,'Flip');
INPUTS.buttons = KbName('g');
INPUTS.device = devices.keyboard;
set_up_keys;
WaitForKeypress;

Screen(INPUTS.window,'Flip');
str = 'Waiting for scanner...';
DrawFormattedText(INPUTS.window,str,'center','center',[255 255 255],50);
Screen(INPUTS.window,'Flip');

% get trigger
t_trigger = WaitForSkyraTrigger(devices);
Screen(INPUTS.window,'Flip');

% give control back to subject
INPUTS.buttons = orig_buttons;
INPUTS.devices = orig_device;
set_up_keys;