function timer_wait(timerStart,secs_since_timerStart)
% Waits till secs_since_timerStart have passed
% 
% How to start the timer: timerStart = GetSecs;

while (GetSecs - timerStart) < secs_since_timerStart
    WaitSecs(0.010) % wait 10ms between each check
end