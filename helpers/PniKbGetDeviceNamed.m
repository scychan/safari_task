function deviceNumber = PniKbGetDeviceNamed(deviceString)
%deviceNumber = PniKbGetDeviceNamed([deviceString])
%
%Will run PsychToolbox's GetKeyboardIndices and return
% the deviceNumber for the name provided. If no name
% provided, will return the main keyboard deviceNumber
if ~exist('deviceString','var')
    deviceString = 'keyboard';
end
wantKeyboard=PniKbIsDeviceKeyboard(deviceString);
[id,name]=GetKeyboardIndices;
deviceNumber=0;
for i=1:length(name)
    if strcmp(name{i},deviceString) || ...
            (wantKeyboard && PniKbIsDeviceKeyboard(name{i}))
        deviceNumber=id(i);
        break;
    end
end