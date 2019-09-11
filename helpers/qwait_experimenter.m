global INPUTS

% get the current settings
orig_device = INPUTS.device;
orig_buttons = INPUTS.buttons;

% change to experimenter settings and wait for keypress
INPUTS.device = devices.keyboard;
INPUTS.buttons = keysets.g;
set_up_keys;
qwait

% change back to original settings
INPUTS.device = orig_device;
INPUTS.buttons = orig_buttons;
set_up_keys;
