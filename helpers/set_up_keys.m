function set_up_keys
% Start a KbQueue for specific device and buttons (ignores others)
%
% NOTE: For proper usage, set 'INPUTS.buttons' and 'INPUTS.device' right before/after

global INPUTS

keyList=zeros(256,1);
keyList(INPUTS.buttons)=1;

% KbQueueRelease()

KbQueueCreate(INPUTS.device,keyList);

while KbCheck; end % Wait until all keys are released.

KbQueueStart();

% THESE DON'T WORK ON MACBOOKS, FOR SOME REASON:
% PsychHID('KbQueueCreate',INPUTS.device,keyList);
% PsychHID('KbQueueStart');