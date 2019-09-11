function isKb = PniKbIsDeviceKeyboard(deviceString)
%isKb = PniSignalsIsDeviceKeyboard(deviceString)
isKb = ~isempty(strfind(lower(deviceString),'keyboard'));
end