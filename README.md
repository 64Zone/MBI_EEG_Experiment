# EEG-Vogel
## [Click here](https://docs.google.com/spreadsheets/d/1ytYdaCX957saaOcHs3VhWsmKEaduBwWNLObMvcJXgKw/edit?usp=sharing) to visit a Google Sheet of example output data
- ### Sheet 1: Vogel task
- ### Sheet 2: Thought Activation task
## Files and directories
- **Pilot_Vogel.m** is the main file that calls the experiment
- **getTrials.m** creates the master sheet of trials, read into Pilot_Vogel.m
- **trialdata/** contains output from getTrials.m, the master sheet for all trials
- Data is logged in **data_/** folder in root directory, previously was in **data/**
- **.gitignore** in root prevents pushing of data to github
