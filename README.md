# Safari Task

Psychtoolbox implementation of the Safari Task.

Chan SCY, Niv Y, Norman KA (2016) A Probability Distribution over Latent Causes, in the Orbitofrontal Cortex. J Neurosci 36:7817?7828.

## To run the task
```
addpath('./helpers')

make_stimlist(subjnum)

soundcheck

run_SAFARI(subjnum, phase, scanning, debug)
```

## Keys to use

Not scanning: u, i
Scanning: 2, 3

## Changes relative to last working version, used in JNeuro paper
- updated to Psychtoolbox 3 (vs 2)
- updated to Matlab 2019 
- updated code to handle renamed functions, etc

## TODO fixes
- sound not working with new Psychtoolbox / new Matlab