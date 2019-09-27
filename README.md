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

## TODO fixes for new Psychtoolbox / new Matlab

These scripts were tested for full compatibility with Psychtoolbox 2 and Matlab 2016.

With Psychtoolbox 3 and Matlab 2019a, the following need to be updated:
- sound (the music in each sector)
- keypresses being read by Psychtoolbox