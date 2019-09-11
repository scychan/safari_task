=== Steps ===
addpath('./helpers')
make_stimlist(subjnum)
soundcheck
run_SAFARI(subjnum, phase, scanning, debug)

=== Keys in use ===


=== Changes relative to last working version, used in JNeuro paper ===
- updated to Psychtoolbox 3 (vs 2)
- updated to Matlab 2019 
- updated code to handle renamed functions, etc